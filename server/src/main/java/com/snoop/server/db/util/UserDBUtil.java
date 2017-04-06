package com.snoop.server.db.util;

import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.snoop.server.db.model.User;

public class UserDBUtil {

  public static String getEmailByUid(
      final Session session,
      final Long uid,
      final boolean newTransaction) {
    final User user = getUserByUid(session, uid, newTransaction);
    return user != null ? user.getPrimaryEmail() : null;
  }

  public static User getUserByUid(
      final Session session,
      final Long uid,
      final boolean newTransaction) {

    final String select = "SELECT U.uid, U.uname, U.primaryEmail, U.createdTime, U.updatedTime"
        + " FROM User AS U WHERE U.uid = %d";
    final String sql = String.format(select, uid);
    return getUserByQuery(session, getQuery(session, sql), newTransaction);
  }

  public static User getUserByUname(
      final Session session,
      final String uname,
      final boolean newTransaction) {

    final String select = "SELECT U.uid, U.uname, U.primaryEmail, U.createdTime, U.updatedTime"
        + " FROM User AS U WHERE U.uname = '%s'";
    final String sql = String.format(select, uname);
    return getUserByQuery(session, getQuery(session, sql), newTransaction);
  }

  private static SQLQuery getQuery(
      final Session session,
      final String sql) {
    /* build query */
    final SQLQuery query = session.createSQLQuery(sql);

    /* add column mapping */
    query.addScalar("uid", new LongType())
         .addScalar("uname", new StringType())
         .addScalar("primaryEmail", new StringType())
         .addScalar("createdTime", new TimestampType())
         .addScalar("updatedTime", new TimestampType());
    return query;
  }

  /**
   * Gets user by a hibernate query. This is a common function for code
   * reusability.
   */
  private static User getUserByQuery(
      final Session session,
      final SQLQuery query,
      final boolean newTransaction) {

    Transaction txn = null;
    List<User> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      query.setResultTransformer(Transformers.aliasToBean(User.class));
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

  public static User getUserWithUidAndPwd(
      final Session session,
      final String uname,
      final boolean newTransaction) {

    final String select = "SELECT U.uid, U.pwd FROM User AS U WHERE U.uname = '%s'";
    final String sql = String.format(select, uname);

    /* build query */
    final SQLQuery query = session.createSQLQuery(sql);

    /* add column mapping */
    query.addScalar("uid", new LongType())
         .addScalar("pwd", new StringType());

    return getUserByQuery(session, query, newTransaction);
  }
}
