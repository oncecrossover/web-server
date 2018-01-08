package com.snoop.server.db.util;

import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.hibernate.type.DateType;
import org.hibernate.type.IntegerType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.Type;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.snoop.server.db.model.PromoEntry;

public class PromoDBUtil {
  public static PromoEntry getPromo(
      final Session session,
      final Long uid,
      final String code,
      final boolean newTransaction) throws Exception {

    final String select = "SELECT DISTINCT P.id, P.uid, P.code, P.amount, P.createdTime,"
        + " P.updatedTime FROM Promo AS P"
        + " WHERE uid = %d AND code = '%s'";
    final String sql = String.format(select, uid, code);

    final List<PromoEntry> list = DBUtil.getEntitiesByQuery(PromoEntry.class,
        session, sql, getScalars(), newTransaction);
    return list.size() == 1 ? list.get(0) : null;
  }

  public static List<PromoEntry> getPromos(
      final Session session,
      final Map<String, List<String>> params,
      final boolean newTransaction) {

      final String sql = buildSql4Promos(params);

      return DBUtil.getEntitiesByQuery(PromoEntry.class, session, sql,
          getScalars(), newTransaction);
    }

    private static String buildSql4Promos(
        final Map<String, List<String>> params) {

      final String select = "SELECT DISTINCT P.id, P.uid, P.code, P.amount, P.createdTime,"
          + " P.updatedTime FROM Promo AS P";

      final List<String> list = Lists.newArrayList();
      for (String key : params.keySet()) {
        switch (key) {
        case "uid":
          list.add(
              String.format("P.uid=%d", Long.parseLong(params.get(key).get(0))));
          break;
        case "code":
          list.add(
              String.format("P.code=%s", params.get(key).get(0)));
          break;
         default:
            break;
        }
      }

      /* query where clause */
      String where = " WHERE ";
      where += list.size() == 0 ?
          "1 = 0" : /* simulate no columns specified */
          Joiner.on(" AND ").skipNulls().join(list);

      return select + where;
    }

  private static Map<String, Type> getScalars() {
    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("uid", new LongType());
    scalars.put("code", new StringType());
    scalars.put("amount", new IntegerType());
    scalars.put("createdTime", new DateType());
    scalars.put("updatedTime", new DateType());
    return scalars;
  }
}
