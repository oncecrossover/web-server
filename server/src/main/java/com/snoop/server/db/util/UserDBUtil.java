package com.snoop.server.db.util;

import java.util.List;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.IntegerType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;
import org.hibernate.type.Type;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.snoop.server.conf.Configuration;
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
    return getUserByQuery(session, sql, getScalars(), newTransaction);
  }

  public static User getUserByUname(
      final Session session,
      final String uname,
      final boolean newTransaction) {

    final String select = "SELECT U.uid, U.uname, U.primaryEmail, U.createdTime, U.updatedTime"
        + " FROM User AS U WHERE U.uname = '%s'";
    final String sql = String.format(select, uname);

    return getUserByQuery(session, sql, getScalars(), newTransaction);
  }

  private static Map<String, Type> getScalars() {
    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("uid", new LongType());
    scalars.put("uname", new StringType());
    scalars.put("primaryEmail", new StringType());
    scalars.put("createdTime", new TimestampType());
    scalars.put("updatedTime", new TimestampType());
    return scalars;
  }

  /**
   * Gets user by a hibernate query. This is a common function for code
   * reusability.
   */
  private static User getUserByQuery(
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    final List<User> list = getUsersByQuery(session, sql, scalars,
        newTransaction);
    return list.size() == 1 ? list.get(0) : null;
  }

  /**
   * Gets a list of users by a hibernate query. This is a common function for
   * code reusability.
   */
  private static List<User> getUsersByQuery(
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    Transaction txn = null;
    List<User> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);

      /* add column mapping */
      for (Map.Entry<String, Type> entry : scalars.entrySet()) {
        query.addScalar(entry.getKey(), entry.getValue());
      }

      /* execute query */
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

    return list;
  }

  public static User getUserWithUidAndPwd(
      final Session session,
      final String uname,
      final boolean newTransaction) {

    final String select = "SELECT U.uid, U.pwd FROM User AS U WHERE U.uname = '%s'";
    final String sql = String.format(select, uname);

    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("uid", new LongType());
    scalars.put("pwd", new StringType());

    return getUserByQuery(session, sql, scalars, newTransaction);
  }

  public static List<User> getUsers(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction) {

    final String sql = buildSql4AllUsers(params);
    return getUsersByQuery(session, sql, getScalars(), newTransaction);
  }

  private static String buildSql4AllUsers(
      final Map<String, List<String>> params) {

    long lastSeenUpdatedTime = 0;
    long lastSeenId = 0;
    int limit = Configuration.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select = "SELECT U.uid, U.uname, U.primaryEmail, U.createdTime, U.updatedTime"
        + " FROM User AS U";
    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      switch (key) {
      case "uid":
        list.add(
            String.format("U.uid=%d", Long.parseLong(params.get(key).get(0))));
        break;
      case "uname":
        list.add(String.format("U.uname LIKE %s", params.get(key).get(0)));
        break;
      case "primaryEmail":
        list.add(
            String.format("U.primaryEmail LIKE %s", params.get(key).get(0)));
        break;
      case "lastSeenId":
        lastSeenId = Long.parseLong(params.get(key).get(0));
        break;
      case "lastSeenUpdatedTime":
        lastSeenUpdatedTime = Long.parseLong(params.get(key).get(0));
        break;
      case "limit":
        limit = Integer.parseInt(params.get(key).get(0));
        break;
      default:
        break;
      }
    }

    /* query where clause */
    String where = " WHERE ";
    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    /* pagination where clause */
    where += DBUtil.getPaginationWhereClause(
        "U.updatedTime",
        lastSeenUpdatedTime,
        "U.uid",
        lastSeenId);

    final String orderBy = " ORDER BY U.updatedTime DESC, U.uid DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + orderBy + limitClause;
  }
}
