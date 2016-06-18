package com.gibbon.peeq.snoop;

import org.apache.commons.lang3.text.StrTokenizer;

class PathStream extends StrTokenizer {
  public PathStream(final String input, final String delim) {
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

public class ResourceURIParser {
  private final String uri;
  private static final String SLASH = "/";
  PathStream ps;

  public ResourceURIParser(final String uri) {
    this.uri = uri;
    ps = new PathStream(uri, SLASH);
  }

  public PathStream getPathStream() {
    return ps;
  }

  public String getURI() {
    return uri;
  }
}
