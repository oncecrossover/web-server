package com.gibbon.peeq.db.util;

import java.math.BigInteger;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.gibbon.peeq.db.model.User;

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

  public static User getUser(
      final Session session,
      final String uid,
      final boolean newTransaction) {

    final String sql = buildSqlToGetUser(uid);

    Transaction txn = null;
    List<User> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(User.class));
      /* add column mapping */
      query.addScalar("uid", new StringType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("updatedTime", new TimestampType());
      list = query.list();

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

    return list.size() == 1 ? list.get(0) : null;
  }

  private static String buildSqlToGetUser(final String uid) {
    final String select = "SELECT U.uid, U.createdTime, U.updatedTime"
        + " FROM User AS U WHERE U.uid = '%s'";
    return String.format(select, uid);
  }

  private static String buildSql4PwdMatched(
      final String uid,
      final String pwd) {
    final String select = "SELECT COUNT(*) FROM User AS U WHERE"
        + " U.uid = '%s' AND U.pwd='%s'";
    return String.format(select, uid, pwd);
  }
}
