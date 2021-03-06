package com.wallchain.server.db.util;

import java.util.List;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.wallchain.server.db.model.CatMappingEntry;

public class CatMappingDBUtil {

  public static CatMappingEntry getCatMappingEntry(
      final Session session,
      final Long catId,
      final Long uid,
      final boolean newTransaction) {

    final String sql = buildSql4CatMappingEntry(catId, uid);
    Transaction txn = null;
    List<CatMappingEntry> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = buildQuery(session, sql);
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

  private static SQLQuery buildQuery(final Session session, final String sql) {
    final SQLQuery query = session.createSQLQuery(sql);
    query.setResultTransformer(Transformers.aliasToBean(CatMappingEntry.class));
    /* add column mapping */
    query.addScalar("id", new LongType())
         .addScalar("catId", new LongType())
         .addScalar("catName", new StringType())
         .addScalar("catDescription", new StringType())
         .addScalar("uid", new LongType())
         .addScalar("isExpertise", new StringType())
         .addScalar("isInterest", new StringType())
         .addScalar("createdTime", new TimestampType())
         .addScalar("updatedTime", new TimestampType());
    return query;
  }

  private static String buildSql4CatMappingEntry(
      final Long catId,
      final Long uid) {
    final String select = "SELECT CM.id, CM.catId,"
        + " C.name AS catName, C.description AS catDescription,"
        + " CM.uid, CM.isExpertise, CM.isInterest, CM.createdTime, CM.updatedTime"
        + " FROM CatMapping AS CM INNER JOIN Category AS C"
        + " ON CM.catId = C.id AND CM.catId = %d WHERE uid = %d";
    return String.format(select, catId, uid);
  }

  public static List<CatMappingEntry> getCatMappingEntries(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction) {

    final String sql = buildSql4CatMappingEntries(params);
    Transaction txn = null;
    List<CatMappingEntry> list = null;
    
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = buildQuery(session, sql);
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

  private static String buildSql4CatMappingEntries(
      final Map<String, List<String>> params) {

    final String select = "SELECT CM.id, CM.catId,"
        + " C.name AS catName, C.description AS catDescription,"
        + " CM.uid, CM.isExpertise, CM.isInterest, CM.createdTime, CM.updatedTime"
        + " FROM CatMapping AS CM INNER JOIN Category AS C"
        + " ON CM.catId = C.id";

    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(String.format("CM.id = %d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("catId".equals(key)) {
        list.add(String.format("CM.catId = %d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("uid".equals(key)) {
        list.add(String.format("CM.uid = %d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("isExpertise".equals(key)) {
        list.add(String.format("CM.isExpertise = %s", params.get(key).get(0)));
      } else if ("isInterest".equals(key)) {
        list.add(String.format("CM.isInterest= %s", params.get(key).get(0)));
      }
    }

    /* query where clause */
    String where = " WHERE C.active='TRUE' AND ";
    where += list.size() == 0 ? "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    return select + where;
  }
}
