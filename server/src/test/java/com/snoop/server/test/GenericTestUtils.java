package com.snoop.server.test;

import java.util.concurrent.TimeoutException;

import org.apache.hadoop.util.Time;

import com.google.common.base.Supplier;

/**
 * Test provides some very generic helpers which might be used across the tests
 */
public abstract class GenericTestUtils {
  public static void waitFor(Supplier<Boolean> check, int checkEveryMillis,
      int waitForMillis) throws TimeoutException, InterruptedException {
    long st = Time.now();
    do {
      boolean result = check.get();
      if (result) {
        return;
      }

      Thread.sleep(checkEveryMillis);
    } while (Time.now() - st < waitForMillis);

    throw new TimeoutException(
        "Timed out waiting for condition. " + "Thread diagnostics:\n"
            + TimedOutTestsListener.buildThreadDiagnosticString());
  }
}
