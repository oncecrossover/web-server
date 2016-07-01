package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import java.util.Map;

import org.junit.Test;

public class TestFilterParameterParser {
  private final static String PREFIX = "profiles?filter=";

  private final String edmundReqUri = String.format("%s%s|%s|%s|%s", PREFIX,
      "uid=edmund", "avatarUrl=https://en.wikiquote.org/wiki/Edmund_Burke",
      "fullName=Edmund Burke", "title=Philosopher");
  private final String loadAllReqUri = String.format("%s%s", PREFIX, "*");
  private final String simpleReqUri = String.format("%s%s", PREFIX,
      "uid=edmund");

  private final String kuanReqUri = String.format("%s=%s|%s|%s|%s", PREFIX,
      "uid=kuan", "avatarUrl=https://en.wikipedia.org/wiki/Guan_Zhong",
      "fullName=Kuan Chung", "title=Chancellor and Reformer");

  @Test(timeout = 60000)
  public void testGetFilter() {
    FilterParameterParser fpp = new FilterParameterParser(edmundReqUri);
    assertEquals("Filter string should equal.", fpp.getFilter(),
        edmundReqUri.substring(PREFIX.length()));
    assertEquals("There must be only one parameter.", fpp.paramCount(), 1);
    assertTrue("There must be 'filter'", fpp.cotnainsKey("filter"));
  }

  @Test(timeout = 60000)
  public void testGetQueryKVs() {
    FilterParameterParser fpp = new FilterParameterParser(edmundReqUri);
    Map<String, String> kvs = fpp.getQueryKVs();
    verifyKeys(kvs);
    verifyValues(kvs);
  }

  @Test
  public void testGetQueryKVsSimple() {
    FilterParameterParser fpp = new FilterParameterParser(simpleReqUri);
    Map<String, String> kvs = fpp.getQueryKVs();
    assertTrue("must contain uid", kvs.containsKey("uid"));
    assertEquals(kvs.get("uid"), "edmund");
  }

  @Test(timeout = 60000)
  public void testGetQueryKVsLoadAll() {
    FilterParameterParser fpp = new FilterParameterParser(loadAllReqUri);
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
    assertEquals(kvs.get("uid"), "edmund");
    assertEquals(kvs.get("avatarUrl"),
        "https://en.wikiquote.org/wiki/Edmund_Burke");
    assertEquals(kvs.get("fullName"), "Edmund Burke");
    assertEquals(kvs.get("title"), "Philosopher");
  }
}