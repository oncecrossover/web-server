package com.gibbon.peeq.snoop;

import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Charsets;

import io.netty.handler.codec.http.QueryStringDecoder;

public class ParameterParser {
  private static final Logger LOG = LoggerFactory
      .getLogger(ParameterParser.class);
  /* should use something like XXXParam in webhdfs */
  public static final String OP = "op";
  public static final String PUT_USER = "putuser";
  public static final String GET_USER = "getuser";
  public static final String RM_USER = "rmuser";
  public static final String UPD_USER = "upduser";
  public static final String UID = "uid";
  public static final String FIRST_NAME = "fname";
  public static final String MIDDLE_NAME = "mname";
  public static final String LAST_NAME = "lname";
  public static final String PWD = "pwd";

  private final String path;
  private final Map<String, List<String>> params;

  ParameterParser(QueryStringDecoder decoder) {
    this.path = QueryStringDecoder.decodeComponent(decoder.path(),
        Charsets.UTF_8);
    params = decoder.parameters();
    LOG.info(decoder.path());
    LOG.info(params.toString());
  }

  String path() {
    return path;
  }

  String getOp() {
    return param(OP);
  }

  String getUid() {
    return param(UID);
  }

  String getFirstName() {
    return param(FIRST_NAME);
  }

  String getMiddleName() {
    return param(MIDDLE_NAME);
  }

  String getLastName() {
    return param(LAST_NAME);
  }

  String getPwd() {
    return param(PWD);
  }

  private String param(String key) {
    List<String> p = params.get(key);
    return p == null ? null : p.get(0);
  }
}
