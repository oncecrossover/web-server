package com.gibbon.peeq.util;

import org.apache.commons.lang3.text.StrTokenizer;

public class ResourcePathStream extends StrTokenizer {
  public ResourcePathStream(final String input, final String delim) {
    super(input, delim);
  }

  public String getPath(int index) {
    reset();
    String path = "";
    int i;
    for (i = 0; i <= index && hasNext(); i++) {
      path = next();
    }
    reset();

    if (i == index || i < index) {
      /*
       * /users, getPath(0) is good, but getPath(1) and getPath(2) will return
       * empty
       */
      return "";
    } else {
      return path;
    }
  }
}