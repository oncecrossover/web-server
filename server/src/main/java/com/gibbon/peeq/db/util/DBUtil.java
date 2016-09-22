package com.gibbon.peeq.db.util;

public class DBUtil {
  /**
   * the time can have duplicate values, so the following sql is necessary.
   * <p>
   * Q.createdTime <= '2016-09-09 08:43:23' AND (Q.id < 7 OR Q.createdTime <
   * '2016-09-09 08:43:23')
   * </p>
   */
  public static String getPaginationClause(
      final String timeColumnName,
      final String lastSeenTime,
      final String idColumnName,
      final long lastSeenId) {
    if (!lastSeenTime.equals("'0'") && lastSeenId != 0) {
      return String.format(
          " AND %s <= %s AND (%s < %d OR %s < %s)",
          timeColumnName,
          lastSeenTime,
          idColumnName,
          lastSeenId,
          timeColumnName,
          lastSeenTime);
    } else {
      return "";
    }
  }
}
