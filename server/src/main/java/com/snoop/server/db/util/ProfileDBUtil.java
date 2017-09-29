package com.snoop.server.db.util;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.IntegerType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.snoop.server.conf.Configuration;
import com.snoop.server.db.model.Profile;
import com.snoop.server.exceptions.SnoopException;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import org.hibernate.type.Type;

public class ProfileDBUtil {

  public static List<Profile> getAllProfilesWithTokens(
      final Session session,
      final boolean newTransaction) {
    final String sql = "SELECT id, deviceToken from Profile where NULLIF(deviceToken, ' ') IS NOT NULL";

    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("deviceToken", new StringType());
    return getProfilesByQuery(session, sql, scalars, newTransaction);
  }

  public static Profile getProfileForNotification(final Session session,
      final Long uid, final boolean newTransaction) {
    final String select = "SELECT id, fullName, deviceToken from Profile WHERE id = %d";
    final String sql = String.format(select, uid);

    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("fullName", new StringType());
    scalars.put("deviceToken", new StringType());

    return getProfileByQuery(session, sql, scalars, newTransaction);
  }

  public static Integer getRate(final Session session, final Long uid,
      final boolean newTransaction) throws Exception {

    final String select = "SELECT rate FROM Profile WHERE id = %d";
    final String sql = String.format(select, uid);

    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("rate", new IntegerType());

    final Profile profile = getProfileByQuery(session, sql, scalars,
        newTransaction);
    if (profile == null) {
      throw new SnoopException(
          String.format("Nonexistent profile for user ('%d')", uid));
    }
    return profile.getRate();
  }

  private static Profile getProfileByQuery(
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    final List<Profile> list = getProfilesByQuery(session, sql, scalars,
        newTransaction);
    return list.size() == 1 ? list.get(0) : null;
  }

  private static List<Profile> getProfilesByQuery(
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    Transaction txn = null;
    List<Profile> list = null;
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
      query.setResultTransformer(Transformers.aliasToBean(Profile.class));
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

  public static List<Profile> getProfiles(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction)  throws Exception {

    final String sql = buildSql4Profiles(params);

    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("rate", new IntegerType());
    scalars.put("avatarUrl", new StringType());
    scalars.put("fullName", new StringType());
    scalars.put("title", new StringType());
    scalars.put("aboutMe", new StringType());
    scalars.put("updatedTime", new TimestampType());
    scalars.put("takeQuestion", new StringType());

    return getProfilesByQuery(session, sql, scalars, newTransaction);
  }

  private static String buildSql4Profiles(
      final Map<String, List<String>> params) {

    long lastSeenUpdatedTime = 0;
    long lastSeenId = 0;
    int limit = Configuration.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select = "SELECT P.id, P.rate, P.avatarUrl, P.fullName,"
        + " P.title, P.aboutMe, P.updatedTime, P.takeQuestion FROM Profile AS P";

    Long uid = 0L;
    String takeQuestion = "''";
    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(
            String.format("P.id=%d", Long.parseLong(params.get(key).get(0))));
      } else if ("uid".equals(key)) {
        uid = Long.parseLong(params.get(key).get(0));
      } else if ("fullName".equals(key)) {
        list.add(String.format(
            "P.fullName LIKE %s",
            params.get(key).get(0)));
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenUpdatedTime".equals(key)) {
        lastSeenUpdatedTime = Long.parseLong(params.get(key).get(0));
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      } else if ("takeQuestion".equals(key)) {
        takeQuestion = params.get(key).get(0);
      }
    }

    /* query where clause */
    String where = " WHERE ";
    /**
     * include login user and the users with specific status, e.g.
     * (P.id = 19049519362609152 OR P.takeQuestion='APPROVED')
     */
    if (takeQuestion != "''" || uid != 0L) {
      where += String.format(" (P.id=%d OR P.takeQuestion=%s) AND ",
          uid, takeQuestion);
    }

    where += list.size() == 0 ?
        "1 = 1" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    /* pagination where clause */
    where += DBUtil.getPaginationWhereClause(
        "P.updatedTime",
        lastSeenUpdatedTime,
        "P.id",
        lastSeenId);

    final String orderBy = " ORDER BY P.updatedTime DESC, P.id DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + orderBy + limitClause;
  }
}
