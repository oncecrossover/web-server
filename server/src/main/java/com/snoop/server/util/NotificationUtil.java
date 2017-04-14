package com.snoop.server.util;

import com.notnoop.apns.APNS;
import com.notnoop.apns.ApnsService;
import com.snoop.server.web.HttpSnoopServer;

public class NotificationUtil {
  private static final String PASSWORD = "Snoop2017";
  private static final String KEY_PATH;
  static {
    if (HttpSnoopServer.LIVE) {
      KEY_PATH = "src/main/resources/com/snoop/server/apns/ProductionPushCertificate.p12";
    } else {
      KEY_PATH = "src/main/resources/com/snoop/server/apns/DevelopmentPushCertificate.p12";
    }
  }

  public static void sendNotification(String title, String message,
      String deviceToken) {
    ApnsService service = APNS.newService()
      .withCert(KEY_PATH, PASSWORD)
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
