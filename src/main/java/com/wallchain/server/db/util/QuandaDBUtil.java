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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.wallchain.server.conf.Configuration;
import com.wallchain.server.db.model.Quanda;
import com.wallchain.server.exceptions.SnoopException;
import com.wallchain.server.model.Answer;
import com.wallchain.server.model.Newsfeed;
import com.wallchain.server.model.Question;

public class QuandaDBUtil {
  protected static final Logger LOG = LoggerFactory.getLogger(QuandaDBUtil.class);

  public static Quanda getQuanda(final Session session, final long id,
      final boolean newTransaction) throws Exception {
    Transaction txn = null;
    Quanda retInstance = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      retInstance = (Quanda) session.get(Quanda.class, id);
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

    if (retInstance == null) {
      throw new SnoopException(String.format("Nonexistent quanda ('%d')", id));
    }

    return retInstance;
  }

  public static List<Quanda> getExpiredQuandas()  throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getExpiredQuandas(session, true);
  }

  public static List<Quanda> getExpiredQuandas(
      final Session session)  throws Exception {
    return getExpiredQuandas(session, false);
  }

  public static List<Quanda> getExpiredQuandas(
      final Session session,
      final boolean newTransaction)  throws Exception {
    final String sql = "SELECT id, asker, responder, rate, status,"
        + " createdTime FROM Quanda WHERE status = 'PENDING' AND"
        + " TIMESTAMPADD(SQL_TSI_HOUR, 48, createdTime) < CURRENT_TIMESTAMP;";
    Transaction txn = null;
    List<Quanda> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Quanda.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("asker", new LongType())
           .addScalar("responder", new LongType())
           .addScalar("rate", new IntegerType())
           .addScalar("status", new StringType())
           .addScalar("createdTime", new TimestampType());
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

  public static List<Answer> getAnswers(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction)  throws Exception {

    final String sql = buildSql4Answers(params);
    Transaction txn = null;
    List<Answer> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Answer.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("question", new StringType())
           .addScalar("status", new StringType())
           .addScalar("rate", new IntegerType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("updatedTime", new TimestampType())
           .addScalar("answerUrl", new StringType())
           .addScalar("answerCoverUrl", new StringType())
           .addScalar("duration", new IntegerType())
           .addScalar("isAskerAnonymous", new StringType())
           .addScalar("askerName", new StringType())
           .addScalar("askerAvatarUrl", new StringType())
           .addScalar("responderId", new LongType())
           .addScalar("responderName", new StringType())
           .addScalar("responderTitle", new StringType())
           .addScalar("responderAvatarUrl", new StringType())
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

  public static List<Question> getQuestions(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction)  throws Exception {

    final String sql = buildSql4Questions(params);
    Transaction txn = null;
    List<Question> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Question.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("question", new StringType())
           .addScalar("status", new StringType())
           .addScalar("rate", new IntegerType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("updatedTime", new TimestampType())
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

  public static List<Newsfeed> getNewsfeed(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction)  throws Exception {

    final String sql = buildSql4Newsfeed(params);
    Transaction txn = null;
    List<Newsfeed> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Newsfeed.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("question", new StringType())
           .addScalar("rate", new IntegerType())
           .addScalar("updatedTime", new TimestampType())
           .addScalar("answerUrl", new StringType())
           .addScalar("answerCoverUrl", new StringType())
           .addScalar("duration", new IntegerType())
           .addScalar("isAskerAnonymous", new StringType())
           .addScalar("askerName", new StringType())
           .addScalar("askerAvatarUrl", new StringType())
           .addScalar("responderId", new LongType())
           .addScalar("responderName", new StringType())
           .addScalar("responderTitle", new StringType())
           .addScalar("responderAvatarUrl", new StringType())
           .addScalar("snoops", new LongType())
           .addScalar("limitedFreeHours", new LongType())
           .addScalar("answeredTime", new TimestampType());
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

  private static String buildSql4Answers(
      final Map<String, List<String>> params) {

    long lastSeenCreatedTime = 0;
    long lastSeenId = 0;
    int limit = Configuration.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select = "SELECT Q.id, Q.question, Q.status, Q.rate,"
        + " Q.createdTime, Q.updatedTime, Q.answerUrl, Q.answerCoverUrl,"
        + " Q.duration, Q.isAskerAnonymous, P.fullName AS askerName,"
        + " P.avatarUrl AS askerAvatarUrl,"
        + " P2.id AS responderId, P2.fullName AS responderName,"
        + " P2.title AS responderTitle, P2.avatarUrl AS responderAvatarUrl,"
        + " count(S.id) AS snoops"
        + " FROM Quanda AS Q"
        + " INNER JOIN Profile AS P ON Q.asker = P.id"
        + " INNER JOIN Profile AS P2 ON Q.responder = P2.id"
        + " LEFT JOIN Snoop AS S ON Q.id = S.quandaId";

    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(String.format(
            "Q.id=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("responder".equals(key)) {
        list.add(String.format("Q.responder=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("lastSeenCreatedTime".equals(key)) {
        lastSeenCreatedTime = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      }
    }

    /* query where clause */
    String where = " WHERE Q.active = 'TRUE' AND Q.status != 'EXPIRED' AND ";
    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    /* pagination where clause */
    where += DBUtil.getPaginationWhereClause(
        "Q.createdTime",
        lastSeenCreatedTime,
        "Q.id",
        lastSeenId);

    final String groupBy = " GROUP BY Q.id";
    final String orderBy = " ORDER BY Q.createdTime DESC, Q.id DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + groupBy + orderBy + limitClause;
  }

  private static String buildSql4Questions(
      final Map<String, List<String>> params) {

    long lastSeenUpdatedTime = 0;
    long lastSeenId = 0;
    int limit = Configuration.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select =
        "SELECT Q.id, Q.question, Q.status, Q.rate, Q.createdTime,"
        + " Q.updatedTime, Q.answerUrl, Q.answerCoverUrl,"
        + " Q.duration, Q.isAskerAnonymous,"
        + " P.id AS responderId, P.fullName AS responderName,"
        + " P.title AS responderTitle, P.avatarUrl AS responderAvatarUrl,"
        + " P2.fullName AS askerName, P2.avatarUrl AS askerAvatarUrl,"
        + " count(S.id) AS snoops"
        + " FROM Quanda AS Q"
        + " INNER JOIN Profile AS P ON Q.responder = P.id"
        + " INNER JOIN Profile AS P2 ON Q.asker = P2.id"
        + " LEFT JOIN Snoop AS S ON Q.id = S.quandaId";

    Long askerId = 0L;
    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(String.format(
            "Q.id=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("asker".equals(key)) {
        askerId = Long.parseLong(params.get(key).get(0));
        list.add(String.format("Q.asker=%d", askerId));
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenUpdatedTime".equals(key)) {
        lastSeenUpdatedTime = Long.parseLong(params.get(key).get(0));
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      }
    }

    /* query where clause */
    String where = " WHERE Q.active = 'TRUE' AND Q.status != 'EXPIRED'"
        /* filter out quandas being already reported by asker */
        + " AND" + getReportFilter()
        /* filter out responders being already blocked by asker */
        + " AND" + getBlockFilter()
        + " AND ";
    where = String.format(where, askerId, askerId);

    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list); /* conditions from list */

    /* pagination where clause */
    where += DBUtil.getPaginationWhereClause(
        "Q.updatedTime",
        lastSeenUpdatedTime,
        "Q.id",
        lastSeenId);

    final String groupBy = " GROUP BY Q.id";
    final String orderBy = " ORDER BY Q.updatedTime DESC, Q.id DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + groupBy + orderBy + limitClause;
  }

  private static String buildSql4Newsfeed(
      final Map<String, List<String>> params) {

    long lastSeenUpdatedTime = 0;
    long lastSeenId = 0;
    int limit = Configuration.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select = " SELECT Q.id, Q.question,"
        + " Q.rate, Q.updatedTime, Q.answerUrl, Q.answerCoverUrl,"
        + " Q.duration, Q.isAskerAnonymous, Q.limitedFreeHours, Q.answeredTime,"
        + " P2.avatarUrl AS askerAvatarUrl, P2.fullName AS askerName,"
        + " P.id AS responderId, P.fullName AS responderName,"
        + " P.title AS responderTitle, P.avatarUrl AS responderAvatarUrl,"
        + " count(S.id) AS snoops"
        + " FROM Quanda AS Q"
        + " INNER JOIN Profile AS P ON Q.responder = P.id"
        + " INNER JOIN Profile AS P2 ON Q.asker = P2.id"
        + " LEFT JOIN Snoop AS S ON Q.id = S.quandaId";

    Long uid = 0L;
    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(String.format(
            "Q.id=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("uid".equals(key)) {
        uid = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenUpdatedTime".equals(key)) {
        lastSeenUpdatedTime = Long.parseLong(params.get(key).get(0));
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      }
    }

    /* query where clause */
    String where = " WHERE Q.asker != %d AND Q.responder != %d"
        + " AND Q.active = 'TRUE' AND Q.status = 'ANSWERED'"
        /* filter out quandas being already snooped */
        + " AND" + getSnoopFilter()
        /* filter out quandas being already reported */
        + " AND" + getReportFilter()
        /* filter out responders being already blocked */
        + " AND" + getBlockFilter()
        + " AND ";
    where = String.format(where, uid, uid, uid, uid, uid);

    where += list.size() == 0 ?
        "1 = 1" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list); /* conditions from list */

    /* pagination where clause */
    where += DBUtil.getPaginationWhereClause(
        "Q.updatedTime",
        lastSeenUpdatedTime,
        "Q.id",
        lastSeenId);

    final String groupBy = " GROUP BY Q.id";
    final String orderBy = " ORDER BY Q.updatedTime DESC, Q.id DESC";
    final String limitClause = String.format(" limit %d;", limit);
    return select + where + groupBy + orderBy + limitClause;
  }

  private static String   getSnoopFilter() {
    return " NOT EXISTS (SELECT DISTINCT S.quandaId FROM Snoop S"
        + " WHERE S.uid = %d AND S.quandaId = Q.id)";
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
