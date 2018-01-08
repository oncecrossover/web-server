package com.snoop.server.db.util;

import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.Type;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.snoop.server.db.model.Thumb;

public class ThumbDBUtil {

  public static Thumb getThumb(
      final Session session,
      final Long uid,
      final Long quandaId,
      final boolean newTransaction) throws Exception {

    final String select = "SELECT DISTINCT T.id, T.uid, T.quandaId, T.upped, T.downed FROM Thumb AS T"
            + " WHERE uid = %d AND quandaId = %d";
    final String sql = String.format(select, uid, quandaId);

    return getThumbByQuery(session, sql, getScalars(), newTransaction);
  }

  public static List<Thumb> getThumbs(
    final Session session,
    final Map<String, List<String>> params,
    final boolean newTransaction) {

    final String sql = buildSql4Thumbs(params);

    return DBUtil.getEntitiesByQuery(Thumb.class, session, sql,
        getScalars(), newTransaction);
  }

  private static String buildSql4Thumbs(
      final Map<String, List<String>> params) {

    final String select = "SELECT DISTINCT T.id, T.uid, T.quandaId, T.upped, T.downed FROM Thumb AS T";

    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      switch (key) {
      case "uid":
        list.add(
            String.format("T.uid=%d", Long.parseLong(params.get(key).get(0))));
        break;
      case "quandaId":
        list.add(
            String.format("T.quandaId=%d", Long.parseLong(params.get(key).get(0))));
        break;
      case "uppped":
        list.add(
            String.format("T.uppped=%s", params.get(key).get(0)));
        break;
      case "downed":
        list.add(
            String.format("T.downed=%s", params.get(key).get(0)));
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

  private static Thumb getThumbByQuery(
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    final List<Thumb> list = DBUtil.getEntitiesByQuery(Thumb.class,
        session, sql, scalars, newTransaction);
    return list.size() == 1 ? list.get(0) : null;
  }

  private static Map<String, Type> getScalars() {
    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("uid", new LongType());
    scalars.put("quandaId", new LongType());
    scalars.put("upped", new StringType());
    scalars.put("downed", new StringType());
    return scalars;
  }
}
