package com.snoop.server.db.util;

import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.snoop.server.db.model.User;

public class UserDBUtil {

  public static String getPwd(
      final Session session,
      final String uid,
      final boolean newTransaction) {

    final String sql = buildSqlToGetPwd(uid);

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
      query.addScalar("pwd", new StringType());
      list = query.list();

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

    return list.size() == 1 ? list.get(0).getPwd() : null;
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
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }

    return list.size() == 1 ? list.get(0) : null;
  }

  private static String buildSqlToGetPwd(final String uid) {
    final String select = "SELECT U.pwd FROM User AS U WHERE U.uid = '%s'";
    return String.format(select, uid);
  }

  private static String buildSqlToGetUser(final String uid) {
    final String select = "SELECT U.uid, U.createdTime, U.updatedTime"
        + " FROM User AS U WHERE U.uid = '%s'";
    return String.format(select, uid);
  }
}
