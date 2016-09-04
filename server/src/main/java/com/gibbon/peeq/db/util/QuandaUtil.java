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

import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.exceptions.SnoopException;
import com.gibbon.peeq.model.Question;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

public class QuandaUtil {
  protected static final Logger LOG = LoggerFactory.getLogger(QuandaUtil.class);

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
           .addScalar("responderName", new StringType())
           .addScalar("responderTitle", new StringType())
           .addScalar("responderAvatarUrl", new StringType())
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
    return list;
  }

  /**
   * SELECT Q.id, Q.question, Q.status, Q.rate, Q.updatedTime, P.fullName AS
   * responderName, P.title AS responderTitle, P.avatarUrl AS responderAvatarUrl
   * FROM Quanda AS Q INNER JOIN Profile AS P ON Q.responder = P.uid WHERE
   * Q.asker='kuan' ORDER BY Q.updatedTime DESC;
   */
  private static String buildSql4Questions(final Map<String, List<String>> params) {
    final String select = "SELECT Q.id, Q.question, Q.status, Q.rate, Q.updatedTime,"
        + " P.fullName AS responderName, P.title AS responderTitle, P.avatarUrl "
        + " AS responderAvatarUrl FROM Quanda AS Q"
        + " INNER JOIN Profile AS P ON Q.responder = P.uid";

    List<String> list = Lists.newArrayList();
    for (String col : params.keySet()) {
      col = col.trim();
      /* skip empty col*/
      if (StringUtils.isBlank(col)) {
        continue;
      }

      if (col.equals("id")) {
        list.add(String.format(
            "Q.id=%d",
            Long.parseLong(params.get(col).get(0))));
      } else if (col.equals("asker")) {
        list.add(String.format("Q.asker=%s", params.get(col).get(0)));
      };
    }

    String where = " WHERE ";
    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);
    final String orderBy = " ORDER BY Q.updatedTime DESC;";
    return select + where + orderBy;
  }
}
