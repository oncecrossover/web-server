package com.gibbon.peeq.db.util;

import java.math.BigInteger;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class UserDBUtil {
  public static boolean pwdMatched(
      final Session session,
      final String uid,
      final String pwd,
      final boolean newTransaction) {
    final String sql = buildSql4PwdMatched(uid, pwd);

    BigInteger result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (BigInteger) session.createSQLQuery(sql).uniqueResult();
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

    /* pwd matched */
    return result.longValue() == 1;
  }

  private static String buildSql4PwdMatched(
      final String uid,
      final String pwd) {
    final String select = "SELECT COUNT(*) FROM User AS U WHERE"
        + " U.uid = '%s' AND U.pwd='%s'";
    return String.format(select, uid, pwd);
  }
}
