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

  public static double getBalanceIgnoreNull(final Session session,
      final String uid) throws Exception {
    final Double result = getBalance(session, uid);
    return result == null ? 0 : result.doubleValue();
  }

  public static Double getBalance(final Session session, final String uid)
      throws Exception {
    final String sql = String
        .format("SELECT SUM(amount) FROM Journal WHERE uid='%s' AND type='BALANCE'", uid);
    Double result = null;
    Transaction txn = null;
    try {
      txn = session.beginTransaction();
      result = (Double) session.createSQLQuery(sql).uniqueResult();
      txn.commit();
    } catch (HibernateException e) {
      txn.rollback();
      throw e;
    } catch (Exception e) {
      throw e;
    }

    return result;
  }

  public static Double getBalance(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getBalance(session, uid);
  }
}
