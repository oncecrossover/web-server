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
import com.snoop.server.db.model.FollowEntry;

public class FollowDBUtil {

  public static FollowEntry getFollowEntry(
      final Session session,
      final Long uid,
      final Long followeeId,
      final boolean newTransaction) throws Exception {

    final String select = String
        .format("SELECT DISTINCT F.id, F.uid, F.followeeId, F.followed FROM Follow AS F"
            + " WHERE uid = %d AND followeeId = %d", uid, followeeId);
    final String sql = String.format(select, uid, followeeId);

    return getFollowEntryByQuery(session, sql, getScalars(), newTransaction);
  }

  public static List<FollowEntry> getFollowEntries(
    final Session session,
    final Map<String, List<String>> params,
    final boolean newTransaction) {

    final String sql = buildSql4Follows(params);

    return DBUtil.getEntitiesByQuery(FollowEntry.class, session, sql,
        getScalars(), newTransaction);
  }

  private static String buildSql4Follows(
      final Map<String, List<String>> params) {

    final String select = "SELECT DISTINCT F.id, F.uid, F.followeeId, F.followed FROM Follow AS F";
    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      switch (key) {
      case "uid":
        list.add(
            String.format("F.uid=%d", Long.parseLong(params.get(key).get(0))));
        break;
      case "followeeId":
        list.add(
            String.format("F.followeeId=%d", Long.parseLong(params.get(key).get(0))));
        break;
      case "followed":
        list.add(
            String.format("F.followed=%s", params.get(key).get(0)));
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

  private static FollowEntry getFollowEntryByQuery(
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    final List<FollowEntry> list = DBUtil.getEntitiesByQuery(FollowEntry.class,
        session, sql, scalars, newTransaction);
    return list.size() == 1 ? list.get(0) : null;
  }

  private static Map<String, Type> getScalars() {
    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("uid", new LongType());
    scalars.put("followeeId", new LongType());
    scalars.put("followed", new StringType());
    return scalars;
  }
}
