package com.wallchain.server.util;

import com.notnoop.apns.APNS;
import com.notnoop.apns.ApnsService;
import com.notnoop.apns.ApnsServiceBuilder;
import com.wallchain.server.web.HttpSnoopServer;

import org.apache.http.protocol.HTTP;

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
      .withAppleDestination(HttpSnoopServer.LIVE)
      .build();
    String payload = APNS.newPayload()
      .alertBody(message)
      .alertTitle(title)
      .sound("default")
      .category("NEWS_CATEGORY").build();
    service.push(deviceToken, payload);
  }
}
