package com.snoop.server.util;

import static org.junit.Assert.*;

import java.util.Map;

import org.junit.Test;

import com.snoop.server.util.FilterParamParser;

public class TestFilterParameterParser {
  private final static String PREFIX = "profiles?filter=";

  private final String edmundReqUri = String.format("%s%s|%s|%s|%s", PREFIX,
      "uid=123456", "avatarUrl=https://en.wikiquote.org/wiki/Edmund_Burke",
      "fullName=Edmund Burke", "title=Philosopher");
  private final String loadAllReqUri = String.format("%s%s", PREFIX, "*");
  private final String simpleReqUri = String.format("%s%s", PREFIX,
      "uid=345678");

  @Test(timeout = 60000)
  public void testGetFilter() {
    FilterParamParser fpp = new FilterParamParser(edmundReqUri);
    assertEquals("Filter string should equal.", fpp.getFilter(),
        edmundReqUri.substring(PREFIX.length()));
    assertEquals("There must be only one parameter.", fpp.paramCount(), 1);
    assertTrue("There must be 'filter'", fpp.containsKey("filter"));
  }

  @Test(timeout = 60000)
  public void testGetQueryKVs() {
    FilterParamParser fpp = new FilterParamParser(edmundReqUri);
    Map<String, String> kvs = fpp.getQueryKVs();
    verifyKeys(kvs);
    verifyValues(kvs);
  }

  @Test
  public void testGetQueryKVsSimple() {
    FilterParamParser fpp = new FilterParamParser(simpleReqUri);
    Map<String, String> kvs = fpp.getQueryKVs();
    assertTrue("must contain uid", kvs.containsKey("uid"));
    assertEquals(kvs.get("uid"), "345678");
  }

  @Test(timeout = 60000)
  public void testGetQueryKVsLoadAll() {
    FilterParamParser fpp = new FilterParamParser(loadAllReqUri);
    Map<String, String> kvs = fpp.getQueryKVs();
    assertTrue("must contain *", kvs.containsKey("*"));
  }

  private void verifyKeys(final Map<String, String> kvs) {
    assertTrue("must contain uid", kvs.containsKey("uid"));
    assertTrue("must contain avatarUrl", kvs.containsKey("avatarUrl"));
    assertTrue("must contain fullName", kvs.containsKey("fullName"));
    assertTrue("must contain title", kvs.containsKey("title"));
  }

  private void verifyValues(final Map<String, String> kvs) {
    assertEquals(kvs.get("uid"), "123456");
    assertEquals(kvs.get("avatarUrl"),
        "https://en.wikiquote.org/wiki/Edmund_Burke");
    assertEquals(kvs.get("fullName"), "Edmund Burke");
    assertEquals(kvs.get("title"), "Philosopher");
  }
}
