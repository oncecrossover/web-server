package com.snoop.server.db.util;

import java.util.List;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.IntegerType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.snoop.server.conf.Configuration;
import com.snoop.server.db.model.Profile;
import com.snoop.server.exceptions.SnoopException;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

public class ProfileDBUtil {

  public static String getDeviceToken(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory().getCurrentSession();
    return getDeviceToken(session, uid, true);
  }

  public static String getDeviceToken(final Session session, final String uid)
    throws Exception {
    return getDeviceToken(session, uid, false);
  }

  static String getDeviceToken(final Session session, final String uid, final boolean newTransaction)
    throws Exception {
    final String sql = String.format("SELECT deviceToken from Profile WHERE uid='%s'", uid);

    String result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (String) session.createSQLQuery(sql).uniqueResult();
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
  /*
   * query from a session that will open new transaction.
   */
  public static Integer getRate(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getRate(session, uid, true);
  }

  /*
   * query from a session that already opened transaction.
   */
  public static Integer getRate(final Session session, final String uid)
      throws Exception {
    return getRate(session, uid, false);
  }

  static Integer getRate(final Session session, final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String.format("SELECT rate FROM Profile WHERE uid='%s'",
        uid);
    Integer result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (Integer) session.createSQLQuery(sql).uniqueResult();
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

    if (result == null) {
      throw new SnoopException(
          String.format("Nonexistent profile for user ('%s')", uid));
    }

    return result;
  }

  public static List<Profile> getProfiles(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction)  throws Exception {

    final String sql = buildSql4Profiles(params);
    Transaction txn = null;
    List<Profile> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Profile.class));
      /* add column mapping */
      query.addScalar("uid", new StringType())
           .addScalar("rate", new IntegerType())
           .addScalar("avatarUrl", new StringType())
           .addScalar("fullName", new StringType())
           .addScalar("title", new StringType())
           .addScalar("aboutMe", new StringType())
           .addScalar("updatedTime", new TimestampType())
           .addScalar("takeQuestion", new StringType());
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

  private static String buildSql4Profiles(
      final Map<String, List<String>> params) {

    long lastSeenUpdatedTime = 0;
    String lastSeenId = "'0'";
    int limit = Configuration.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select = "SELECT P.uid, P.rate, P.avatarUrl, P.fullName,"
        + " P.title, P.aboutMe, P.updatedTime, P.takeQuestion FROM Profile AS P";

    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("uid".equals(key)) {
        list.add(String.format("P.uid=%s", params.get(key).get(0)));
      } else if ("fullName".equals(key)) {
        list.add(String.format(
            "P.fullName LIKE %s",
            params.get(key).get(0)));
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = params.get(key).get(0);
      } else if ("lastSeenUpdatedTime".equals(key)) {
        lastSeenUpdatedTime = Long.parseLong(params.get(key).get(0));
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      } else if ("takeQuestion".equals(key)) {
        list.add(String.format(
            "P.takeQuestion=%s",
            params.get(key).get(0)));
      }
    }

    /* query where clause */
    String where = " WHERE ";
    where += list.size() == 0 ?
        "1 = 1" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    /* pagination where clause */
    where += DBUtil.getPaginationWhereClause(
        "P.updatedTime",
        lastSeenUpdatedTime,
        "P.uid",
        lastSeenId);

    final String orderBy = " ORDER BY P.updatedTime DESC, P.uid DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + orderBy + limitClause;
  }
}
