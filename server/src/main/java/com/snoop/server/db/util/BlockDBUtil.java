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
import com.snoop.server.db.model.BlockEntry;
import com.snoop.server.db.model.User;

public class BlockDBUtil {

  public static BlockEntry getBlockEntry(
      final Session session,
      final Long uid,
      final Long blockeeId,
      final boolean newTransaction) throws Exception {

    final String select = String
        .format("SELECT B.id, B.uid, B.blockeeId, B.blocked FROM Block AS B"
            + " WHERE uid = %d AND blockeeId = %d", uid, blockeeId);
    final String sql = String.format(select, uid, blockeeId);

    return getBlockEntryByQuery(session, sql, getScalars(), newTransaction);
  }

  public static List<BlockEntry> getBlockEntries(
    final Session session,
    final Map<String, List<String>> params,
    final boolean newTransaction) {

    final String sql = buildSql2CheckIfBlocked(params);

    return DBUtil.getEntitiesByQuery(BlockEntry.class, session, sql,
        getScalars(), newTransaction);
  }

  private static String buildSql2CheckIfBlocked(
      final Map<String, List<String>> params) {

    final String select = "SELECT B.id, B.uid, B.blockeeId, B.blocked FROM Block AS B";
    final List<String> list = Lists.newArrayList();
    for (String key : params.keySet()) {
      switch (key) {
      case "uid":
        list.add(
            String.format("B.uid=%d", Long.parseLong(params.get(key).get(0))));
        break;
      case "blockeeId":
        list.add(
            String.format("B.blockeeId=%d", Long.parseLong(params.get(key).get(0))));
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

  private static BlockEntry getBlockEntryByQuery(
      final Session session,
      final String sql,
      final Map<String, Type> scalars,
      final boolean newTransaction) {

    final List<BlockEntry> list = DBUtil.getEntitiesByQuery(BlockEntry.class,
        session, sql, scalars, newTransaction);
    return list.size() == 1 ? list.get(0) : null;
  }

  private static Map<String, Type> getScalars() {
    final Map<String, Type> scalars = Maps.newHashMap();
    scalars.put("id", new LongType());
    scalars.put("uid", new LongType());
    scalars.put("blockeeId", new LongType());
    scalars.put("blocked", new StringType());
    return scalars;
  }
}
