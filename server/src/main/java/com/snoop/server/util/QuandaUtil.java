package com.snoop.server.util;

import java.util.Date;
import java.util.concurrent.TimeUnit;

public class QuandaUtil {

  public static Long getHoursToExpire(final Date createdTime) {
    if (createdTime == null) {
      return 0L;
    }

    /* time diff */
    final Date now = new Date();
    final long diff = now.getTime() - createdTime.getTime();
    if (diff < 0) {
      return 0L;
    }

    /* diff in terms of hours */
    final long hours = TimeUnit.MILLISECONDS.toHours(diff);
    return 48 <= hours ? 0 : 48 - hours;
  }
}
