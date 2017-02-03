package com.gibbon.peeq.util;

import com.notnoop.apns.APNS;
import com.notnoop.apns.ApnsService;

public class NotificationUtil {
  public static String password = "Snoop2017";
  public static String keyPath = "DevelopmentPushCertificate.p12";

  public static void sendNotification(String message, String title, String deviceToken) {
    ApnsService service = APNS.newService()
      .withCert(keyPath, password)
      .withSandboxDestination()
      .build();
    String payload = APNS.newPayload()
      .alertBody(message)
      .alertTitle(title)
      .sound("default")
      .category("NEWS_CATEGORY").build();
    service.push(deviceToken, payload);
  }
}
