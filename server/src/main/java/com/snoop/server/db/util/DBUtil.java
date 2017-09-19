package com.snoop.server.db.util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.Type;

public class DBUtil {

  public static <T> T getEntityByQuery(
      final Class<T> entityClass,
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {
    final List<T> list = getEntitiesByQuery(entityClass, session, sql, scalars,
        newTransaction);
    return list.size() == 1 ? list.get(0) : null;
  }

  public static <T> List<T> getEntitiesByQuery(final Class<T> entityClass,
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    Transaction txn = null;
    List<T> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);

      /* add column mapping */
      for (Map.Entry<String, Type> entry : scalars.entrySet()) {
        query.addScalar(entry.getKey(), entry.getValue());
      }

      /* execute query */
      query.setResultTransformer(Transformers.aliasToBean(entityClass));
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

  /**
   * the time can have duplicate values, so the following sql is necessary.
   * <p>
   * Q.createdTime <= '2016-09-09 08:43:23' AND (Q.id < 7 OR Q.createdTime <
   * '2016-09-09 08:43:23')
   * </p>
   */
  public static String getPaginationWhereClause(
      final String timeColumnName,
      final long lastSeenTime,
      final String idColumnName,
      final long lastSeenId) {

    if (lastSeenTime != 0 && lastSeenId != 0) {
      final String lastSeenlocalTime = longToTimeString(lastSeenTime);
      return String.format(
          " AND %s <= '%s' AND (%s < %d OR %s < '%s')",
          timeColumnName,
          lastSeenlocalTime,
          idColumnName,
          lastSeenId,
          timeColumnName,
          lastSeenlocalTime);
    } else {
      return "";
    }
  }

  private static String longToTimeString(final long lastSeenTime) {
    return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        .format(new Date(lastSeenTime));
  }
}
