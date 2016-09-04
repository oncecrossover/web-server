package com.gibbon.peeq.util;

import io.netty.handler.codec.http.QueryStringDecoder;

public class ResourcePathParser {
  private final String uri;
  private static final String SLASH = "/";
  ResourcePathStream ps;

  public ResourcePathParser(final String uri) {
    this.uri = uri;
    /**
     * use QueryStringDecoder to remove anything including and after '?'
     * "/profiles/edmund?filter=*" --> "/profiles/edmund"
     */
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
