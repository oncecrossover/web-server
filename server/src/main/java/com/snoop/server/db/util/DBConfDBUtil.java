package com.snoop.server.db.util;

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
import com.snoop.server.db.model.DBConf;

public class DBConfDBUtil {

  public static List<DBConf> getDBConfs(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction) {

    final String sql = buildSql4DBConfs(params);
    Transaction txn = null;
    List<DBConf> list = null;

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

  private static SQLQuery buildQuery(final Session session, final String sql) {
    final SQLQuery query = session.createSQLQuery(sql);
    query.setResultTransformer(Transformers.aliasToBean(DBConf.class));
    /* add column mapping */
    query.addScalar("id", new LongType())
         .addScalar("ckey", new StringType())
         .addScalar("value", new StringType())
         .addScalar("defaultValue", new StringType())
         .addScalar("description", new StringType())
         .addScalar("createdTime", new TimestampType())
         .addScalar("updatedTime", new TimestampType());
    return query;
  }

  private static String buildSql4DBConfs(
      final Map<String, List<String>> params) {

    final String select = "SELECT C.id, C.ckey, C.value, C.defaultValue,"
        + " C.description, C.createdTime, C.updatedTime"
        + " FROM Configuration AS C";

    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      switch (key) {
      case "id":
        list.add(
            String.format("C.id = %d", Long.parseLong(params.get(key).get(0))));
        break;
      case "ckey":
        list.add(String.format("C.ckey = %s", params.get(key).get(0)));
        break;
      default:
        break;
      }
    }

    /* query where clause */
    String where = " WHERE ";
    where += list.size() == 0 ? "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    return select + where;
  }
}
