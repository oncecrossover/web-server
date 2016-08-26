package com.gibbon.peeq.db.util;

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

import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.exceptions.SnoopException;

public class QaTransactionUtil {

  public static QaTransaction getQaTransaction(
      final String uid,
      final String transType,
      final long quandaId) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getQaTransaction(session, uid, transType, quandaId, true);
  }

  public static QaTransaction getQaTransaction(
      final Session session,
      final String uid,
      final String transType,
      final long quandaId) throws Exception {
    return getQaTransaction(session, uid, transType, quandaId, false);
  }

  static QaTransaction getQaTransaction(
      final Session session,
      final String uid,
      final String transType,
      final long quandaId,  
      final boolean newTransaction) throws Exception {
    /* build sql */
    final String sql = String.format(
        "SELECT * FROM QaTransaction WHERE uid = '%s' AND type = '%s' AND quandaId = '%d';",
        uid, transType, quandaId);

    Transaction txn = null;
    List<QaTransaction> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(QaTransaction.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("uid", new StringType())
           .addScalar("type", new StringType())
           .addScalar("quandaId", new LongType())
           .addScalar("amount", new DoubleType())
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
          String.format("Nonexistent qaTransaction ('%s, %s, %s')", uid,
              transType, quandaId));
    }

    if (list.size() != 1) {
      throw new SnoopException(
          String.format("Inconsistent state of qaTransaction ('%s, %s, %s')",
              uid, transType, quandaId));
    }

    return list.get(0);
  }
}
