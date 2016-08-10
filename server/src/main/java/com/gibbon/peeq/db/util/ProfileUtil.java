package com.gibbon.peeq.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.gibbon.peeq.exceptions.SnoopException;

public class ProfileUtil {

  /*
   * query from a session that will open new transaction.
   */
  public static Double getRate(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getRate(session, uid, true);
  }

  /*
   * query from a session that already opened transaction.
   */
  public static Double getRate(final Session session, final String uid)
      throws Exception {
    return getRate(session, uid, false);
  }

  static Double getRate(final Session session, final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String.format("SELECT rate FROM Profile WHERE uid='%s'",
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

    if (result == null) {
      throw new SnoopException(
          String.format("Nonexistent profile for user ('%s')", uid));
    }

    return result;
  }
}
