package com.wallchain.server.util;

import java.util.Date;
import java.util.concurrent.TimeUnit;

public class QuandaUtil {

  public static Long getFreeForHours(final Long limitedFreeHours,
      final Date answeredTime) {
    if (limitedFreeHours == null || answeredTime == null) {
      return 0L;
    }

    return getHoursToDeadline(answeredTime, 48);
  }

  public static Long getHoursToExpire(final Date createdTime) {
    if (createdTime == null) {
      return 0L;
    }

    return getHoursToDeadline(createdTime, 48);
  }

  private static Long getHoursToDeadline(final Date baseTime, final int periodInHours) {
    /* time diff */
    final Date now = new Date();
    final long diff = now.getTime() - baseTime.getTime();
    if (diff < 0) {
      return 0L;
    }

    /* diff in terms of hours */
    final long hours = TimeUnit.MILLISECONDS.toHours(diff);
    return periodInHours <= hours ? 0L : periodInHours - hours;
  }
}
