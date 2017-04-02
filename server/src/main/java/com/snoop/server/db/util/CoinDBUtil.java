package com.snoop.server.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.type.IntegerType;

public class CoinDBUtil {

  public static int getCoinsIgnoreNull(
      final Long uid,
      final Session session,
      final boolean newTransaction) throws Exception {
    final Integer result = getCoins(session, uid, newTransaction);
    return result == null ? 0 : result.intValue();
  }

  static Integer getCoins(
      final Session session,
      final Long uid,
      final boolean newTransaction) throws Exception {
    final String sql = String
        .format("SELECT SUM(amount) As total FROM Coin WHERE uid = %d", uid);
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
