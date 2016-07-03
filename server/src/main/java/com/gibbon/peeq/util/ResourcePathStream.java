package com.gibbon.peeq.util;

import org.apache.commons.lang3.text.StrTokenizer;

public class ResourcePathStream extends StrTokenizer {
  public ResourcePathStream(final String input, final String delim) {
    super(input, delim);

  }

  /* memorize the most recent touched path */
  private String touched;

  /*
   * Gets the most recent touched path.
   * @return the most recent touched path.
   */
  public String getTouched() {
    return touched;
  }

  @Override
  public String next() {
    touched = super.next();
    return touched;
  }

  @Override
  public String nextToken() {
    touched = super.nextToken();
    return touched;
  }

  @Override
  public String previous() {
    touched = super.previous();
    return touched;
  }

  @Override
  public String previousToken() {
    touched = super.previousToken();
    return touched;
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