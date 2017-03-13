package com.gibbon.peeq.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.type.IntegerType;

public class CoinDBUtil {

  public static int getCoinsIgnoreNull(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    final Integer result = getCoins(session, uid, true);
    return result == null ? 0 : result.intValue();
  }

  public static int getCoinsIgnoreNull(
      final String uid,
      final Session session,
      final boolean newTransaction) throws Exception {
    final Integer result = getCoins(session, uid, newTransaction);
    return result == null ? 0 : result.intValue();
  }

  static Integer getCoins(
      final Session session,
      final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String
        .format("SELECT SUM(amount) As total FROM Coin WHERE uid = '%s'", uid);
    Integer result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (Integer) session.createSQLQuery(sql)
          .addScalar("total", IntegerType.INSTANCE).uniqueResult();
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
