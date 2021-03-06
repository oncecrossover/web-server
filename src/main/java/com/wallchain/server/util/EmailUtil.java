package com.wallchain.server.util;

import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;

import org.apache.commons.lang.text.StrBuilder;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EmailUtil {
  private static final Logger LOG = LoggerFactory.getLogger(EmailUtil.class);
  final static int LEN_PWD = 6;
  final static String CHARACTERS =
      "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ234567890!@#$%^&*()_+";
  private final static String USER_NAME = "no-reply@vinsider.com";
  private final static String PASS_WORD = "Sn@@pntf*#@$";
  private final static String PERSONAL = "CryptoGo Team";

  public static String getRandomPwd() {
    return RandomStringUtils.random(LEN_PWD, CHARACTERS);
  }

  private static Session getEmailSession() {
    final Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.socketFactory.port", "465");
    props.put("mail.smtp.socketFactory.class",
        "javax.net.ssl.SSLSocketFactory");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.port", "465");

    final Session session = Session.getDefaultInstance(props,
        new javax.mail.Authenticator() {
          protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(USER_NAME, PASS_WORD);
          }
        });
    return session;
  }

  public static void sendPaymentConfirmation(
      final String email,
      final String action,
      final String question,
      final double amount) {

    if (StringUtils.isEmpty(email)) {
      return;
    }

    try {
      final Message message = new MimeMessage(getEmailSession());
      message.setFrom(new InternetAddress(USER_NAME, PERSONAL));
      message.setRecipients(Message.RecipientType.TO,
          InternetAddress.parse(email));
      message.setSubject("Payment confirmation from " + PERSONAL);

      /* set email body */
      final StrBuilder sb = new StrBuilder();
      sb.appendln("Dear user,");
      sb.appendln("");
      sb.appendln(String.format("We received your payment $%.2f for %s", amount,
          action));
      sb.appendln("");
      sb.append("\"");
      sb.append(question);
      sb.append("\".");
      sb.appendln("");
      sb.appendln("");
      sb.appendln("Thanks,");
      sb.appendln("CryptoGo Team");
      message.setText(sb.toString());

      Transport.send(message);
    } catch (Exception e) {
      final StrBuilder sb = new StrBuilder();
      sb.appendln(String.format(
          "Error in sending payment confirmation to %s for "
              + "asking or snooping",
          email));
      sb.appendln("");
      sb.append("\"");
      sb.append(question);
      sb.append("\".");
      sb.appendln("");
      LOG.warn(sb.toString(), e);
    }
  }

  public static void sendTempPwd(final String email, final String tmpPwd) {

    if (StringUtils.isBlank(email)) {
      return;
    }

    try {
      final Message message = new MimeMessage(getEmailSession());
      message.setFrom(new InternetAddress(USER_NAME, PERSONAL));
      message.setRecipients(Message.RecipientType.TO,
          InternetAddress.parse(email));
      message.setSubject("Temporary password for your CryptoGo account");

      /* set email body */
      final StrBuilder sb = new StrBuilder();
      sb.appendln("Dear user,");
      sb.appendln("");
      sb.appendln("This is your temp password: " + tmpPwd);
      sb.appendln("It will be expired in 24 hours,"
          + " or invalidated by next request of reseting password.");
      sb.appendln("");
      sb.appendln("");
      sb.appendln("Thanks,");
      sb.appendln("CryptoGo Team");
      message.setText(sb.toString());

      Transport.send(message);
    } catch (Exception e) {
      final StrBuilder sb = new StrBuilder();
      sb.appendln(String.format("Error in sending temporary password to %s.", email));
      LOG.warn(sb.toString(), e);
    }
  }
}
