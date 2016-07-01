package com.gibbon.peeq.util;

import io.netty.handler.codec.http.QueryStringDecoder;

public class ResourceURIParser {
  private final String uri;
  private static final String SLASH = "/";
  ResourcePathStream ps;

  public ResourceURIParser(final String uri) {
    this.uri = uri;
    String path = new QueryStringDecoder(uri).path();
    ps = new ResourcePathStream(path, SLASH);
  }

  public ResourcePathStream getPathStream() {
    return ps;
  }

  public String getURI() {
    return uri;
  }
}
