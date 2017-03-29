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
import com.snoop.server.db.model.Category;

public class CategoryDBUtil {

  public static List<Category> getCategories(
      Session session,
      Map<String, List<String>> params,
      final boolean newTransaction) {

    final String sql = buildSql4AllCategories(params);
    Transaction txn = null;
    List<Category> list = null;

    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Category.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("name", new StringType())
           .addScalar("description", new StringType())
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

  private static String buildSql4AllCategories(
      final Map<String, List<String>> params) {

    final String select =
        "SELECT C.id, C.name, C.description, C.createdTime, C.updatedTime"
        +" FROM Category AS C";
    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      if ("id".equals(key)) {
        list.add(
            String.format("C.id=%d", Long.parseLong(params.get(key).get(0))));
      } else if ("name".equals(key)) {
        list.add(String.format("C.name LIKE %s", params.get(key).get(0)));
      }
    }

    /* query where clause */
    String where = " WHERE ";
    where += list.size() == 0 ? "1 = 0" : /* simulate no columns specified */
        Joiner.on(" AND ").skipNulls().join(list);

    return select + where;
  }
}
