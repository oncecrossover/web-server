package com.snoop.server.util;

import static org.junit.Assert.*;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.snoop.server.util.Encryptor;

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
