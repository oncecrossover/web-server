package com.wallchain.server.util;

import org.apache.commons.lang3.text.StrTokenizer;

public class ResourcePathStream extends StrTokenizer {
  public ResourcePathStream(final String input, final String delim) {
    super(input, delim);

  }

  /* memorize the path touched most recently */
  private String touchedPath;

  /* memorize the index of path touched most recently */
  private int touchedIndex;

  /*
   * Gets the path touched most recently.
   * @return the path touched most recently.
   */
  public String getTouchedPath() {
    return touchedPath;
  }

  /*
   * Gets the index of path touched most recently.
   * @return the index of path touched most recently.
   */
  public int getTouchedIndex() {
    return touchedIndex;
  }

  public void pointTo(final int index) {
    for (int i = 0; i < index; i++) {
      this.nextToken();
    }
  }

  @Override
  public String next() {
    throw new UnsupportedOperationException();
  }

  @Override
  public String nextToken() {
    touchedIndex = super.nextIndex();
    touchedPath = super.nextToken();
    return touchedPath;
  }

  @Override
  public String previous() {
    throw new UnsupportedOperationException();
  }

  @Override
  public String previousToken() {
    touchedIndex = super.previousIndex();
    touchedPath = super.previousToken();
    return touchedPath;
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