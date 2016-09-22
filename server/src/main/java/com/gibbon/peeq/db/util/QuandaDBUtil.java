package com.gibbon.peeq.db.util;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.DoubleType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.conf.SnoopServerConf;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.exceptions.SnoopException;
import com.gibbon.peeq.model.Answer;
import com.gibbon.peeq.model.Newsfeed;
import com.gibbon.peeq.model.Question;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

public class QuandaDBUtil {
  protected static final Logger LOG = LoggerFactory.getLogger(QuandaDBUtil.class);

  /*
   * query from a session that will open new transaction.
   */
  public static Quanda getQuanda(final long id) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getQuanda(session, id, true);
  }

  /*
   * query from a session that already opened transaction.
   */
  public static Quanda getQuanda(final Session session, final long id)
      throws Exception {
    return getQuanda(session, id, false);
  }

  static Quanda getQuanda(final Session session, final long id,
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
      if (txn != null) {
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
           .addScalar("asker", new StringType())
           .addScalar("responder", new StringType())
           .addScalar("rate", new DoubleType())
           .addScalar("status", new StringType())
           .addScalar("createdTime", new TimestampType());
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
           .addScalar("rate", new DoubleType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("askerName", new StringType())
           .addScalar("askerTitle", new StringType())
           .addScalar("askerAvatarUrl", new StringType());
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
           .addScalar("rate", new DoubleType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("updatedTime", new TimestampType())
           .addScalar("responderName", new StringType())
           .addScalar("responderTitle", new StringType())
           .addScalar("responderAvatarUrl", new StringType());
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
           .addScalar("updatedTime", new TimestampType())
           .addScalar("responderId", new StringType())
           .addScalar("responderName", new StringType())
           .addScalar("responderTitle", new StringType())
           .addScalar("responderAvatarUrl", new StringType())
           .addScalar("snoops", new LongType());
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
    return list;
  }

  /**
   * SELECT Q.id, Q.question, Q.status, Q.rate, Q.createdTime, P.fullName AS
   * askerName, P.title AS askerTitle, P.avatarUrl AS askerAvatarUrl FROM Quanda
   * AS Q INNER JOIN Profile AS P ON Q.asker = P.uid WHERE Q.id=1 ORDER BY
   * Q.updatedTime DESC;
   */
  private static String buildSql4Answers(
      final Map<String, List<String>> params) {

    String lastSeenCreatedTime = "'0'";
    long lastSeenId = 0;
    int limit = SnoopServerConf.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select = "SELECT Q.id, Q.question, Q.status, Q.rate,"
        + " Q.createdTime, P.fullName AS askerName,"
        + " P.title AS askerTitle, P.avatarUrl AS askerAvatarUrl"
        + " FROM Quanda AS Q"
        + " INNER JOIN Profile AS P ON Q.asker = P.uid";

    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(String.format(
            "Q.id=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("responder".equals(key)) {
        list.add(String.format("Q.responder=%s", params.get(key).get(0)));
      } else if ("lastSeenCreatedTime".equals(key)) {
        lastSeenCreatedTime = params.get(key).get(0);
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      }
    }

    /* query where clause */
    String where = " WHERE Q.status != 'EXPIRED' AND ";
    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    /* pagination where clause */
    where += DBUtil.getPaginationClause(
        "Q.createdTime",
        lastSeenCreatedTime,
        "Q.id",
        lastSeenId);

    final String orderBy = " ORDER BY Q.createdTime DESC, Q.id DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + orderBy + limitClause;
  }

  /**
   * SELECT Q.id, Q.question, Q.status, Q.rate, Q.createdTime, Q.updatedTime,
   * P.fullName AS responderName, P.title AS responderTitle, P.avatarUrl AS
   * responderAvatarUrl FROM Quanda AS Q INNER JOIN Profile AS P ON Q.responder
   * = P.uid WHERE Q.id=1 ORDER BY Q.updatedTime DESC;
   */
  private static String buildSql4Questions(
      final Map<String, List<String>> params) {

    String lastSeenUpdatedTime = "'0'";
    long lastSeenId = 0;
    int limit = SnoopServerConf.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select = "SELECT Q.id, Q.question, Q.status, Q.rate,"
        + " Q.createdTime, Q.updatedTime, P.fullName AS responderName,"
        + " P.title AS responderTitle, P.avatarUrl AS responderAvatarUrl"
        + " FROM Quanda AS Q"
        + " INNER JOIN Profile AS P ON Q.responder = P.uid";

    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(String.format(
            "Q.id=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("asker".equals(key)) {
        list.add(String.format("Q.asker=%s", params.get(key).get(0)));
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenUpdatedTime".equals(key)) {
        lastSeenUpdatedTime = params.get(key).get(0);
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      }
    }

    /* query where clause */
    String where = " WHERE Q.active = 'TRUE' AND ";
    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    /* pagination where clause */
    where += DBUtil.getPaginationClause(
        "Q.updatedTime",
        lastSeenUpdatedTime,
        "Q.id",
        lastSeenId);

    final String orderBy = " ORDER BY Q.updatedTime DESC, Q.id DESC";
    final String limitClause = String.format(" limit %d;", limit);

    return select + where + orderBy + limitClause;
  }

  private static String buildSql4Newsfeed(
      final Map<String, List<String>> params) {

    String lastSeenUpdatedTime = "'0'";
    long lastSeenId = 0;
    int limit = SnoopServerConf.SNOOP_SERVER_CONF_PAGINATION_LIMIT_DEFAULT;
    final String select =
        "SELECT Q.id, Q.question, Q.updatedTime," +
        " P.uid AS responderId, P.fullName AS responderName," +
        " P.title AS responderTitle, P.avatarUrl AS responderAvatarUrl," +
        " count(S.id) AS snoops FROM" +
        " Quanda AS Q INNER JOIN Profile AS P ON Q.responder = P.uid" +
        " LEFT JOIN Snoop AS S ON Q.id = S.quandaId";

    String uid = "NULL";
    List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("uid".equals(key)) {
        uid = params.get(key).get(0);
      } else if ("lastSeenId".equals(key)) {
        lastSeenId = Long.parseLong(params.get(key).get(0));
      } else if ("lastSeenUpdatedTime".equals(key)) {
        lastSeenUpdatedTime = params.get(key).get(0);
      } else if ("limit".equals(key)) {
        limit = Integer.parseInt(params.get(key).get(0));
      }
    }

    /* query where clause */
    String where = " WHERE Q.asker != %s AND Q.responder != %s"
        + " AND Q.status = 'ANSWERED' AND NOT EXISTS"
        + " (SELECT DISTINCT S.quandaId FROM Snoop S"
        + " WHERE S.uid = %s AND S.quandaId = Q.id)";
    where = String.format(where, uid, uid, uid);

    /* pagination where clause */
    where += DBUtil.getPaginationClause(
        "Q.updatedTime",
        lastSeenUpdatedTime,
        "Q.id",
        lastSeenId);

    final String groupBy = " GROUP BY Q.id";
    final String orderBy = " ORDER BY Q.updatedTime DESC, Q.id DESC";
    final String limitClause = String.format(" limit %d;", limit);
    return select + where + groupBy + orderBy + limitClause;
  }
}
