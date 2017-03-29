package com.snoop.server.db.util;

import java.math.BigInteger;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.DoubleType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.snoop.server.db.model.Journal;
import com.snoop.server.db.model.QaTransaction;
import com.snoop.server.db.model.Quanda;
import com.snoop.server.db.model.Journal.JournalType;
import com.snoop.server.exceptions.SnoopException;
import com.snoop.server.web.handlers.BalanceWebHandler;

public class JournalUtil {
  private static final Logger LOG = LoggerFactory
      .getLogger(BalanceWebHandler.class);

  /*
   * query from a session that will open new transaction.
   * @return balance, return 0 in case of null.
   */
  public static double getBalanceIgnoreNull(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    final Double result = getBalance(session, uid, true);
    return result == null ? 0 : result.doubleValue();
  }

  static Double getBalance(
      final Session session,
      final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String
        .format("SELECT SUM(amount) AS total FROM Journal WHERE uid='%s'"
            + "  AND type='BALANCE'", uid);
    Double result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (Double) session.createSQLQuery(sql)
          .addScalar("total", DoubleType.INSTANCE).uniqueResult();
      if (txn != null) {
        txn.commit();
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }

    return result;
  }

  public static Journal getPendingJournal(final QaTransaction qaTransaction)
      throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getPendingJournal(session, qaTransaction, true);
  }

  public static Journal getPendingJournal(
      final Session session,
      final QaTransaction qaTransaction) throws Exception {
    return getPendingJournal(session, qaTransaction, false);
  }

  static Journal getPendingJournal(
      final Session session,
      final QaTransaction qaTransaction,
      final boolean newTransaction) throws Exception {
    /* build sql */
    final String sql = String.format(
        "SELECT * FROM Journal WHERE transactionId = %d AND uid = '%s' AND"
            + " amount = %s AND status = 'PENDING' AND originId IS NULL;",
        qaTransaction.getId(),
        qaTransaction.getUid(),
        Double.toString(-1 * qaTransaction.getAmount()));

    Transaction txn = null;
    List<Journal> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Journal.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("transactionId", new LongType())
           .addScalar("uid", new StringType())
           .addScalar("amount", new DoubleType())
           .addScalar("type", new StringType())
           .addScalar("chargeId", new StringType())
           .addScalar("status", new StringType())
           .addScalar("originId", new LongType())
           .addScalar("createdTime", new TimestampType());
      list = query.list();

      if (txn != null) {
        txn.commit();
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }

    if (list == null || list.size() == 0) {
      throw new SnoopException(
          String.format(
              "Nonexistent journal (transactionId:%d, uid:%s, amount:%s, status:PENDING, originId:NULL)",
              qaTransaction.getId(),
              qaTransaction.getUid(),
              Double.toString(-1 * qaTransaction.getAmount())));
    }

    if (list.size() != 1) {
      throw new SnoopException(
          String.format(
              "Inconsistent journal (transactionId:%d, uid:%s, amount:%s, status:PENDING, originId:NULL)",
              qaTransaction.getId(),
              qaTransaction.getUid(),
              Double.toString(-1 * qaTransaction.getAmount())));
    }

    return list.get(0);
  }

  public static boolean pendingJournalCleared(
      final Session session,
      final Journal pendingJournal) throws Exception {
    return pendingJournalCleared(session, pendingJournal, false);
  }

  public static boolean pendingJournalCleared(
      final Session session,
      final Journal pendingJournal,
      final boolean newTransaction) throws Exception {

    /* build chargeId sub clause */
    String chargeIdSubClause = null;
    if (pendingJournal.getChargeId() == null) {
      chargeIdSubClause = "chargeId IS NULL";
    } else {
      chargeIdSubClause = String.format(
          "chargeId = '%s'",
          pendingJournal.getChargeId());
    }

    /* build sql */
    final String sql = String.format(
        "SELECT COUNT(*) FROM Journal WHERE transactionId = %d AND uid = '%s'"
            + " AND amount = 0 AND type = '%s' AND %s AND"
            + " status = 'CLEARED' AND originId = %d;",
            pendingJournal.getTransactionId(),
            pendingJournal.getUid(),
            pendingJournal.getType(),
            chargeIdSubClause,
            pendingJournal.getId());

    Transaction txn = null;
    BigInteger result = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      /* build query */
      result = (BigInteger) session.createSQLQuery(sql).uniqueResult();
      if (txn != null) {
        txn.commit();
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }

    if (result.longValue() > 1) {
      throw new SnoopException(
          "Inconsistent journal: " + pendingJournal.toJsonStr());
    }

    /* the pending journal is cleared */
    return result.longValue() == 1;
  }

  public static Journal insertClearanceJournal(
      final Session session,
      final Journal pendingJournal) throws Exception {
    return insertClearanceJournal(session, pendingJournal, false);
  }

  /* insert clearance journal */
  public static Journal insertClearanceJournal(
      final Session session,
      final Journal pendingJournal,
      final boolean newTransaction) throws Exception {

    final Journal clearanceJournal = new Journal();
    clearanceJournal.setTransactionId(pendingJournal.getTransactionId())
                    .setUid(pendingJournal.getUid())
                    .setAmount(0)
                    .setType(pendingJournal.getType())
                    .setChargeId(pendingJournal.getChargeId())
                    .setStatus(Journal.Status.CLEARED.value())
                    .setOriginId(pendingJournal.getId());

    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      session.save(clearanceJournal);
      if (txn != null) {
        txn.commit();
      }
      return clearanceJournal;
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }
  }

  public static Journal insertResponderJournal(
      final Session session,
      final Journal clearanceJournal,
      final Quanda quanda) throws Exception {
    return insertResponderJournal(session, clearanceJournal, quanda, false);
  }

  /* insert responder journal */
  public static Journal insertResponderJournal(
      final Session session,
      final Journal clearanceJournal,
      final Quanda quanda,
      final boolean newTransaction) throws Exception {

    final Journal responderJournal = new Journal();
    responderJournal.setTransactionId(clearanceJournal.getTransactionId())
                    .setUid(quanda.getResponder())
                    .setAmount(quanda.getPayment4Responder())
                    .setType(Journal.JournalType.BALANCE.value())
                    .setStatus(Journal.Status.CLEARED.value())
                    .setOriginId(clearanceJournal.getId());

    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      session.save(responderJournal);
      if (txn != null) {
        txn.commit();
      }
      return responderJournal;
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }
  }

  public static Journal insertRefundJournal(
      final Session session,
      final Journal clearanceJournal,
      final Quanda quanda) throws Exception {
    return insertRefundJournal(session, clearanceJournal, quanda, false);
  }

  /* insert refund journal */
  public static Journal insertRefundJournal(
      final Session session,
      final Journal clearanceJournal,
      final Quanda quanda,
      final boolean newTransaction) throws Exception {

    final Journal refundJournal = new Journal();
    refundJournal.setTransactionId(clearanceJournal.getTransactionId())
                 .setUid(quanda.getAsker())
                 .setAmount(Math.abs(quanda.getRate()))
                 .setType(JournalType.BALANCE.value())
                 .setChargeId(clearanceJournal.getChargeId())
                 .setStatus(Journal.Status.REFUNDED.value())
                 .setOriginId(clearanceJournal.getId());

    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      session.save(refundJournal);
      if (txn != null) {
        txn.commit();
      }
      return refundJournal;
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }
  }
}
