package com.gibbon.peeq.util;

public class ResourceURIParser {
  private final String uri;
  private static final String SLASH = "/";
  ResourcePathStream ps;

  public ResourceURIParser(final String uri) {
    this.uri = uri;
    ps = new ResourcePathStream(uri, SLASH);
  }

  public ResourcePathStream getPathStream() {
    return ps;
  }

  public String getURI() {
    return uri;
  }
}
