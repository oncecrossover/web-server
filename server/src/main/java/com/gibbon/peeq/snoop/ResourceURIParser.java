package com.gibbon.peeq.snoop;

import org.apache.commons.lang3.text.StrTokenizer;

class PathStream extends StrTokenizer {
  public PathStream(final String input, final String delim) {
    super(input, delim);
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
}
