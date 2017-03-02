package com.gibbon.peeq.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.type.LongType;

public class CoinDBUtil {

  public static long getCoinsIgnoreNull(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    final Long result = getCoins(session, uid, true);
    return result == null ? 0 : result.longValue();
  }

  static Long getCoins(
      final Session session,
      final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String
        .format("SELECT SUM(amount) As total FROM Coin WHERE uid = '%s'", uid);
    Long result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (Long) session.createSQLQuery(sql)
          .addScalar("total", LongType.INSTANCE).uniqueResult();
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

}
