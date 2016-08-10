package com.gibbon.peeq.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.gibbon.peeq.exceptions.SnoopException;

public class PcAccountUtil {

  /*
   * query from a session that will open new transaction.
   */
  public static String getCustomerId(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getCustomerId(session, uid, true);
  }

  /*
   * query from a session that already opened transaction.
   */
  public static String getCustomerId(final Session session, final String uid)
      throws Exception {
    return getCustomerId(session, uid, false);
  }

  static String getCustomerId(final Session session, final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String
        .format("SELECT chargeFrom FROM PcAccount WHERE uid='%s'", uid);

    Transaction txn = null;
    String result = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (String) session.createSQLQuery(sql).uniqueResult();
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
          String.format("Nonexistent customer for user ('%s')", uid));
    }

    return result;
  }
}
