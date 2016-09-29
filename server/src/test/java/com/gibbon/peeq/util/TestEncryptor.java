package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestEncryptor {
  private static final Logger LOG = LoggerFactory
      .getLogger(TestEncryptor.class);

  @Test
  public void testEncryptPassword() {
    final String pwd = "super!@#$%strong^&*(pwd!";
    final String encodedPwd = Encryptor.encode(pwd);
    LOG.info(encodedPwd);
    assertTrue(Encryptor.checkPassword(pwd, encodedPwd));
  }
}
