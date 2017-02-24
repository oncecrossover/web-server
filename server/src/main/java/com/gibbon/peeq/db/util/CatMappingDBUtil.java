package com.gibbon.peeq.db.util;

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

import com.gibbon.peeq.db.model.CatMappingEntry;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;

public class CatMappingDBUtil {

  public static CatMappingEntry getCatMappingEntry(
      final Session session,
      final Long catId,
      final String uid,
      final boolean newTransaction) {

    final String sql = buildSql4CatMappingEntry(catId, uid);
    Transaction txn = null;
    List<CatMappingEntry> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(CatMappingEntry.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("catId", new LongType())
           .addScalar("uid", new StringType())
           .addScalar("isExpertise", new StringType())
           .addScalar("isInterest", new StringType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("updatedTime", new TimestampType());
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

  private static String buildSql4CatMappingEntry(
      final Long catId,
      final String uid) {
    final String select = "SELECT CM.id, CM.catId, CM.uid, CM.isExpertise,"
        + " CM.isInterest, CM.createdTime, CM.updatedTime FROM CatMapping AS CM"
        + " WHERE catId=%d AND uid='%s'";
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
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(CatMappingEntry.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("catId", new LongType())
           .addScalar("uid", new StringType())
           .addScalar("isExpertise", new StringType())
           .addScalar("isInterest", new StringType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("updatedTime", new TimestampType());
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

    final String select = "SELECT CM.id, CM.catId, CM.uid, CM.isExpertise,"
        + " CM.isInterest, CM.createdTime, CM.updatedTime FROM CatMapping AS CM";

    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(
            String.format("CM.id=%d", Long.parseLong(params.get(key).get(0))));
      } else if ("catId".equals(key)) {
        list.add(String.format("CM.catId=%d",
            Long.parseLong(params.get(key).get(0))));
      } else if ("uid".equals(key)) {
        list.add(String.format("CM.uid=%s", params.get(key).get(0)));
      } else if ("isExpertise".equals(key)) {
        list.add(String.format("CM.isExpertise=%s", params.get(key).get(0)));
      } else if ("isInterest".equals(key)) {
        list.add(String.format("CM.isInterest=%s", params.get(key).get(0)));
      }
    }

    /* query where clause */
    String where = " WHERE ";
    where += list.size() == 0 ? "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    return select + where;
  }
}
