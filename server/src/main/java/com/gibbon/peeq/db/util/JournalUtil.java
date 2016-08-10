package com.gibbon.peeq.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
  public static double getBalanceIgnoreNull(final Session session,
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
  public static Double getBalance(final Session session, final String uid)
      throws Exception {
    return getBalance(session, uid, false);
  }

  static Double getBalance(final Session session, final String uid,
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
}
