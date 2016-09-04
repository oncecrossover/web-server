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

import com.gibbon.peeq.db.model.Snoop;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

public class SnoopUtil {

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

    final String sql = buildSql(params);
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
           .addScalar("rate", new DoubleType())
           .addScalar("responderName", new StringType())
           .addScalar("responderTitle", new StringType())
           .addScalar("responderAvatarUrl", new StringType())
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

  /**
   * SELECT S.id, Q.id AS quandaId, Q.question, Q.status, Q.rate, P.fullName AS
   * responderName, P.title AS responderTitle, P.avatarUrl AS
   * responderAvatarUrl, S.createdTime FROM Snoop AS S INNER JOIN Quanda AS Q ON
   * S.quandaId = Q.id INNER JOIN Profile AS P ON Q.responder = P.uid WHERE
   * Q.status = 'ANSWERED' AND S.uid='edmund' ORDER BY createdTime DESC;
   */
  private static String buildSql(final Map<String, List<String>> params) {
    String select = "SELECT S.id, Q.id AS quandaId, Q.question, Q.status, Q.rate,"
        + " P.fullName AS responderName, P.title AS responderTitle,"
        + " P.avatarUrl AS responderAvatarUrl, S.createdTime"
        + " FROM Snoop AS S INNER JOIN"
        + " Quanda AS Q ON S.quandaId = Q.id INNER JOIN Profile AS P"
        + " ON Q.responder = P.uid";

    List<String> list = Lists.newArrayList();
    for (String col : params.keySet()) {
      col = col.trim();
      /* skip empty col, e.g. /snoops?" " */
      if (StringUtils.isBlank(col)) {
        continue;
      }

      if (col.equals("id")) {
        list.add(
            String.format("S.id=%d", Long.parseLong(params.get(col).get(0))));
      } else if (col.equals("uid")) {
        list.add(String.format("S.uid=%s", params.get(col).get(0)));
      } else if (col.equals("quandaId")) {
        list.add(String.format("S.quandaId=%d",
            Long.parseLong(params.get(col).get(0))));
      } else if (col.equals("createdTime")) {
        list.add(String.format("S.createdTime=%s", params.get(col).get(0)));
      } else {
        list.add(String.format("S.%s=%s", col, params.get(col).get(0)));
      }
    }

    String where = " WHERE Q.status = 'ANSWERED' AND ";
    where += list.size() == 0 ?
        "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);
    final String orderBy = " ORDER BY createdTime DESC;";
    return select + where + orderBy;
  }
}
