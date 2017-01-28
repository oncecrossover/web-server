package com.gibbon.peeq.util;

import static org.junit.Assert.assertEquals;

import java.io.UnsupportedEncodingException;

import javax.mail.MessagingException;
import javax.mail.internet.AddressException;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestEmailUtil {
  static final Logger LOG = LoggerFactory.getLogger(TestEmailUtil.class);

  @Test(timeout = 60000)
  public void testSendTempPwd() {
    EmailUtil.sendTempPwd("osmedev@gmail.com", EmailUtil.getRandomPwd());
  }

  @Test(timeout = 60000)
  public void testCreateRandomPwd() {
    final String pwd1 = EmailUtil.getRandomPwd();
    LOG.info("random pwd1: " + pwd1);
    final String pwd2 = EmailUtil.getRandomPwd();
    LOG.info("random pwd2: " + pwd2);
    assertEquals(false, pwd1.equals(pwd2));
  }
}
