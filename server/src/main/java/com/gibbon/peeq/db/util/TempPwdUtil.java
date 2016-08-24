package com.gibbon.peeq.db.util;

import java.math.BigInteger;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class TempPwdUtil {
  /*
   * Execute query from a session that will open new transaction.
   * @return The number of entities updated or deleted.
   */
  public static int expireAllPendingPwds(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return expireAllPendingPwds(session, uid, true);
  }

  /*
   * Execute query from a session that already opened transaction.
   * @return The number of entities updated or deleted.
   */
  public static int expireAllPendingPwds(final Session session,
      final String uid) throws Exception {
    return expireAllPendingPwds(session, uid, false);
  }

  /*
   * Execute query from a session that will open new transaction.
   * @return true if uid/pwd/PENDING exists, otherwise false.
   */
  public static boolean tempPwdExists4User(final String uid, final String pwd)
      throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return tempPwdExists4User(session, uid, pwd, true);
  }

  /*
   * Execute query from a session that already opened transaction.
   * @return true if uid/pwd/PENDING exists, otherwise false.
   */
  public static boolean tempPwdExists4User(final Session session,
      final String uid, final String pwd) throws Exception {
    return tempPwdExists4User(session, uid, pwd, false);
  }

  static boolean tempPwdExists4User(final Session session, final String uid,
      final String pwd, final boolean newTransaction) throws Exception {
    final String sql = String
        .format("SELECT COUNT(*) FROM TempPwd WHERE uid = '%s'"
            + " AND pwd = '%s' AND status = 'PENDING';", uid, pwd);
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      final BigInteger result = (BigInteger) session.createSQLQuery(sql)
          .uniqueResult();
      if (txn != null) {
        txn.commit();
      }
      return result.longValue() != 0;
    } catch (HibernateException e) {
      if (txn != null) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }
  }

  static int expireAllPendingPwds(final Session session, final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String
        .format("UPDATE TempPwd SET status = 'EXPIRED' WHERE uid = '%s'"
            + " AND status = 'PENDING';", uid);
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      final int result = session.createSQLQuery(sql).executeUpdate();
      if (txn != null) {
        txn.commit();
      }
      return result;
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
