package com.snoop.server.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.netty.handler.codec.http.QueryStringDecoder;

public class QueryParamsParser {
  private QueryStringDecoder qsd;
  private String uri;

  public QueryParamsParser(final String uri) {
    this(uri, true);
  }

  public QueryParamsParser(final String uri, final boolean hasPath) {
    qsd = new QueryStringDecoder(uri, hasPath);
    this.uri = uri;
  }

  /**
   * Returns the decoded key-value parameter pairs of the URI.
   */
  public Map<String, List<String>> params() {
    return qsd.parameters();
  }

  /**
   * Returns the decoded path string of the URI.
   */
  public String path() {
    return qsd.path();
  }

  public int paramCount() {
    return params().size();
  }

  public boolean containsKey(final String key) {
    return params().containsKey(key);
  }

  public String param(String key) {
    List<String> p = params().get(key);
    return p == null ? null : p.get(0);
  }

  public List<String> params(String key) {
    List<String> p = params().get(key);
    return p == null ? new ArrayList<String>() : p;
  }
}
