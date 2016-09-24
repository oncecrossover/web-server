package com.gibbon.peeq.db.util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class DBUtil {
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

  public static String getPaginationWhereClause(
      final String timeColumnName,
      final long lastSeenTime,
      final String idColumnName,
      final String lastSeenId) {

    if (lastSeenTime != 0 && !lastSeenId.equals('0')) {
      final String lastSeenlocalTime = longToTimeString(lastSeenTime);
      return String.format(
          " AND %s <= '%s' AND (%s < %s OR %s < '%s')",
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
}
