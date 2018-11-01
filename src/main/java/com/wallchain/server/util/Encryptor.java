package com.wallchain.server.util;

import org.jasypt.util.password.StrongPasswordEncryptor;

public class Encryptor {

  public static String encode(final String text) {
    final StrongPasswordEncryptor passwordEncryptor = new StrongPasswordEncryptor();
    return passwordEncryptor.encryptPassword(text);
  }

  public static boolean checkPassword(final String pwd,
      final String encodedPwd) {
    final StrongPasswordEncryptor passwordEncryptor = new StrongPasswordEncryptor();

    if (passwordEncryptor.checkPassword(pwd, encodedPwd)) {
      return true;
    } else {
      return false;
    }
  }
}
