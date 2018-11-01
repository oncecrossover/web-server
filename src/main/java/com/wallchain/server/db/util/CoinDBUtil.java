package com.wallchain.server.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.type.IntegerType;

import com.wallchain.server.db.model.CoinEntry;
import com.wallchain.server.db.model.Journal;
import com.wallchain.server.db.model.Quanda;

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

  public static CoinEntry insertRefundCoins(
      final Session session,
      final Journal clearanceJournal,
      final Quanda quanda,
      final int refundCoins) throws Exception {
    return insertRefundCoins(session, clearanceJournal, quanda, refundCoins, false);
  }

  public static CoinEntry insertRefundCoins(
      final Session session,
      final Journal clearanceJournal,
      final Quanda quanda,
      final int refundCoins,
      final boolean newTransaction) throws Exception {

    final CoinEntry refundCoinEntry = new CoinEntry();
    refundCoinEntry.setUid(quanda.getAsker())
                   .setAmount(refundCoins)
                   .setOriginId(clearanceJournal.getCoinEntryId());

    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      session.save(refundCoinEntry);
      if (txn != null) {
        txn.commit();
      }
      return refundCoinEntry;
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
