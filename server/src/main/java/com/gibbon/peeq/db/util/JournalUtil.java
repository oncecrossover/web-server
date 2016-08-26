package com.gibbon.peeq.db.util;

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

import com.gibbon.peeq.db.model.Journal;
import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.exceptions.SnoopException;
import com.gibbon.peeq.handlers.BalanceWebHandler;

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

  /*
   * query from a session that already opened transaction.
   * @return balance, return 0 in case of null.
   */
  public static double getBalanceIgnoreNull(
      final Session session,
      final String uid) throws Exception {
    final Double result = getBalance(session, uid, false);
    return result == null ? 0 : result.doubleValue();
  }

  /*
   * query from a session that will open new transaction.
   * @return balance, could be null.
   */
  public static Double getBalance(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getBalance(session, uid, true);
  }

  /*
   * query from a session that already opened transaction.
   * @return balance, could be null.
   */
  public static Double getBalance(
      final Session session,
      final String uid) throws Exception {
    return getBalance(session, uid, false);
  }

  static Double getBalance(
      final Session session,
      final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String.format(
        "SELECT SUM(amount) FROM Journal WHERE uid='%s' AND type='BALANCE'",
        uid);
    Double result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (Double) session.createSQLQuery(sql).uniqueResult();
      if (txn != null) {
        txn.commit();
      }
    } catch (HibernateException e) {
      if (txn != null) {
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
      if (txn != null) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }

    if (list == null || list.size() == 0) {
      throw new SnoopException(
          String.format(
              "Nonexistent journal (transactionId:%d, uid:%s, amount:%s, status:PENDING', originId:NULL)",
              qaTransaction.getId(),
              qaTransaction.getUid(),
              Double.toString(-1 * qaTransaction.getAmount())));
    }

    if (list.size() != 1) {
      throw new SnoopException(
          String.format(
              "Inconsistent journal (transactionId:%d, uid:%s, amount:%s, status:PENDING', originId:NULL)",
              qaTransaction.getId(),
              qaTransaction.getUid(),
              Double.toString(-1 * qaTransaction.getAmount())));
    }

    return list.get(0);
  }

  public static boolean pendingJournalCleared(
      final Session session,
      final Journal journal) throws Exception {
    return pendingJournalCleared(session, journal, false);
  }

  public static boolean pendingJournalCleared(
      final Session session,
      final Journal journal,
      final boolean newTransaction) throws Exception {
    /* build sql */
    final String sql = String.format(
        "SELECT COUNT(*) FROM Journal WHERE transactionId = %d AND uid = '%s'"
            + " AND  amount = 0 AND type = '%s' AND chargeId = '%s' AND"
            + " status = 'CLEARED' AND originId = %d;",
            journal.getTransactionId(),
            journal.getUid(),
            journal.getType(),
            journal.getChargeId(),
            journal.getId());

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
      if (txn != null) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }

    if (result.longValue() > 1) {
      throw new SnoopException("Inconsistent journal: " + journal.toJsonStr());
    }

    /* the pending journal is cleared */
    return result.longValue() != 0;
  }

  public static Journal insertClearanceJournal(
      final Session session,
      final Journal pendingJournal,
      final QaTransaction qaTransaction) throws Exception {
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
      if (txn != null) {
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
                    .setAmount(quanda.getPayment4Answer())
                    .setType(Journal.JournalType.BALANCE.toString())
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
      if (txn != null) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }
  }
}
