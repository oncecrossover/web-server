package com.gibbon.peeq.util;

import java.io.UnsupportedEncodingException;
import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;

import org.apache.commons.lang.text.StrBuilder;
import org.apache.commons.lang3.RandomStringUtils;

public class EmailUtil {
  final static int LEN_PWD = 6;
  final static String CHARACTERS =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()_+";

  public static String getRandomPwd() {
    return RandomStringUtils.random(LEN_PWD, CHARACTERS);
  }

  public static void sendTempPwd(final String uid, final String tmpPwd)
      throws MessagingException, UnsupportedEncodingException {
    final String userName = "snoopmedev@gmail.com";
    final String password = "Sn@@pmd@1";

    final Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.socketFactory.port", "465");
    props.put("mail.smtp.socketFactory.class",
        "javax.net.ssl.SSLSocketFactory");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.port", "465");

    Session session = Session.getDefaultInstance(props,
        new javax.mail.Authenticator() {
          protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(userName, password);
          }
        });

    try {
      final Message message = new MimeMessage(session);
      message.setFrom(new InternetAddress(userName, "Snoop Inc"));
      message.setRecipients(Message.RecipientType.TO,
          InternetAddress.parse(uid));
      message.setSubject("Reset password by receiving temp password");

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
      sb.appendln("Snoop Team");
      message.setText(sb.toString());

      Transport.send(message);
    } catch (MessagingException e) {
      throw e;
    }
  }
}