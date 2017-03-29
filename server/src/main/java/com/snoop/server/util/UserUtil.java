package com.snoop.server.util;

import org.apache.commons.lang3.StringUtils;

import com.snoop.server.db.model.User;

public class UserUtil {
  public static void encryptPwd(final User user) {
    if (user != null && !StringUtils.isBlank(user.getPwd())) {
      user.setPwd(Encryptor.encode(user.getPwd()));
    }
  }

  public static boolean checkPassword(
      final String pwd,
      final String encodedPwd) {
    return Encryptor.checkPassword(pwd, encodedPwd);
  }
}
