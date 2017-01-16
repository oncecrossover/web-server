package com.gibbon.peeq.db.util;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.hibernate.transform.Transformers;
import org.hibernate.type.DoubleType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.gibbon.peeq.conf.SnoopServerConf;
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.exceptions.SnoopException;
import com.gibbon.peeq.util.FilterParamParser;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

public class ProfileDBUtil {

  /*
   * query from a session that will open new transaction.
   */
  public static Double getRate(final String uid) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getRate(session, uid, true);
  }

  /*
   * query from a session that already opened transaction.
   */
  public static Double getRate(final Session session, final String uid)
      throws Exception {
    return getRate(session, uid, false);
  }

  static Double getRate(final Session session, final String uid,
      final boolean newTransaction) throws Exception {
    final String sql = String.format("SELECT rate FROM Profile WHERE uid='%s'",
        uid);
    Double result = null;
    Transaction txn = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      result = (Double) session.createSQLQuery(sql).uniqueResult();
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
           .addScalar("rate", new DoubleType())
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
    int limit = SnoopServerConf.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
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
