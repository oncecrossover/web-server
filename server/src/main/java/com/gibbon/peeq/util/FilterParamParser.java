package com.gibbon.peeq.util;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import com.google.common.base.Charsets;

import io.netty.handler.codec.http.QueryStringDecoder;

public class FilterParamParser {
  public final static String FILTER = "filter";
  public final static String SB_OR = "|";
  public final static String SB_ASSIGN = "=";
  public final static String SB_STAR = "*";
  private QueryStringDecoder decoder;
  private final Map<String, List<String>> params;

  public FilterParamParser(final String reqUri) {
    decoder = new QueryStringDecoder(reqUri);
    params = decoder.parameters();
  }

  public String getFilter() {
    return param(FILTER);
  }

  /*
   * /resource?filter=<column_name>=<column_value>, or resource?filter*, e.g.
   * /profiles?filter=uid=edmund, or /profiles?filter=*
   */
  public Map<String, String> getQueryKVs() {
    Map<String, String> kvs = new HashMap<String, String>();
    final String filter = getFilter();
    for (String kv : filter.split(Pattern.quote(SB_OR))) {
      String[] pv = kv.split(SB_ASSIGN);
      if (pv.length == 1 && SB_STAR.equalsIgnoreCase(pv[0])) {
        kvs.put(pv[0], pv[0]);
      }
      if (pv.length != 2) {
        continue;
      }
      kvs.put(pv[0], pv[1]);
    }

    return kvs;
  }

  public int paramCount() {
    return params.size();
  }

  public Boolean containsKey(final String key) {
    return params.containsKey(key);
  }

  private String param(String key) {
    List<String> p = params.get(key);
    return p == null ? null : p.get(0);
  }
}
