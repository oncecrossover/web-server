package com.wallchain.server.db.util;

import java.util.List;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.LongType;
import org.hibernate.type.IntegerType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.wallchain.server.conf.Configuration;
import com.wallchain.server.db.model.Snoop;

public class SnoopDBUtil {

  public static List<Snoop> getSnoops(
      final Map<String, List<String>> params) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getSnoops(session, params, true);
  }

  public static List<Snoop> getSnoops(
      final Session session,
      final Map<String, List<String>> params) throws Exception {
    return getSnoops(session, params, false);
  }

  public static List<Snoop> getSnoops(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction)  throws Exception {

    final String sql = buildSql4Snoops(params);
    Transaction txn = null;
    List<Snoop> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Snoop.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("quandaId", new LongType())
           .addScalar("question", new StringType())
           .addScalar("status", new StringType())
           .addScalar("rate", new IntegerType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("answerUrl", new StringType())
           .addScalar("answerCoverUrl", new StringType())
           .addScalar("duration", new IntegerType())
           .addScalar("isAskerAnonymous", new StringType())
           .addScalar("responderId", new LongType())
           .addScalar("responderName", new StringType())
           .addScalar("responderTitle", new StringType())
           .addScalar("responderAvatarUrl", new StringType())
           .addScalar("askerName", new StringType())
           .addScalar("askerAvatarUrl", new StringType())
           .addScalar("snoops", new LongType());

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

  private static String buildSql4Snoops(
      final Map<String, List<String>> params) {

    long lastSeenCreatedTime = 0;
    long lastSeenId = 0;
    int limit = Configuration.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    String select = "SELECT S.id, S.createdTime,"
        + " Q.id AS quandaId, Q.question, Q.status, Q.rate, Q.answerUrl,"
        + " Q.answerCoverUrl, Q.duration, Q.isAskerAnonymous,"
        + " P.id AS responderId,"
        + " P.fullName AS responderName, P.title AS responderTitle,"
        + " P.avatarUrl AS responderAvatarUrl, P2.fullName AS askerName,"
        + " P2.avatarUrl AS askerAvatarUrl,"
        + " count(S2.id) AS snoops"
        + " FROM Snoop AS S"
        + " INNER JOIN Quanda AS Q ON S.quandaId = Q.id"
        + " INNER JOIN Profile AS P ON Q.responder = P.id"
        + " INNER JOIN Profile AS P2 on Q.asker = P2.id"
        + " LEFT JOIN Snoop AS S2 ON S.quandaId = S2.quandaId";

    Long uid = 0L;
    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(String.format(
            "S.id=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("uid".equals(key)) {
        uid = Long.parseLong(params.get(key).get(0));
        list.add(String.format("S.uid=%d", uid));
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenCreatedTime".equals(key)) {
        lastSeenCreatedTime = Long.parseLong(params.get(key).get(0));
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      }
    }

    /* query where clause */
    String where = " WHERE Q.active = 'TRUE' AND Q.status = 'ANSWERED'"
        /* filter out quandas being already reported */
        + " AND" + getReportFilter()
        /* filter out responders being already blocked */
        + " AND" + getBlockFilter()
        + " AND ";
    where = String.format(where, uid, uid);

    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list); /* conditions from list */

    /* pagination where clause */
    where += DBUtil.getPaginationWhereClause(
        "S.createdTime",
        lastSeenCreatedTime,
        "S.id",
        lastSeenId);

    final String groupBy = " GROUP BY S.quandaId";
    final String orderBy = " ORDER BY S.createdTime DESC, S.id DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + groupBy + orderBy + limitClause;
  }

  private static String getReportFilter() {
    return " NOT EXISTS (SELECT DISTINCT R.quandaId FROM Report R"
        + " WHERE R.uid = %d AND R.quandaId = Q.id)";
  }

  private static String getBlockFilter() {
    return " NOT EXISTS (SELECT DISTINCT B.blockeeId FROM Block B"
        + " WHERE B.uid = %d AND B.blockeeId = Q.responder AND B.blocked = 'TRUE')";
  }
}
