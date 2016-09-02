package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import org.junit.Test;

public class TestQueryParamsParser {
  @Test(timeout = 60000)
  public void testParserSingleParam() {
    QueryParamsParser parser = new QueryParamsParser(
        "/hello?recipient=world");
    assertEquals(parser.path(), "/hello");
    assertEquals(parser.params().get("recipient").get(0), "world");
    assertEquals(parser.param("recipient"), "world");
  }

  @Test(timeout = 60000)
  public void testParserWithPath() {
    QueryParamsParser parser = new QueryParamsParser(
        "/hello?recipient=world&x=1;y=2");
    assertEquals(parser.path(), "/hello");
    assertEquals(parser.params().get("recipient").get(0), "world");
    assertEquals(parser.params().get("x").get(0), "1");
    assertEquals(parser.params().get("y").get(0), "2");

    assertEquals(parser.param("recipient"), "world");
    assertEquals(parser.param("x"), "1");
    assertEquals(parser.param("y"), "2");

    assertEquals(parser.paramCount(), 3);
  }

  @Test(timeout = 60000)
  public void testParserWithoutPath() {
    QueryParamsParser parser = new QueryParamsParser(
        "recipient=world&x=1;y=2", false);
    assertEquals(parser.path(), "");
    assertEquals(parser.params().get("recipient").get(0), "world");
    assertEquals(parser.params().get("x").get(0), "1");
    assertEquals(parser.params().get("y").get(0), "2");
  }

  @Test(timeout = 60000)
  public void testParserWithValueList() {
    QueryParamsParser parser = new QueryParamsParser(
        "/hello?recipient=world&x=1;y=2&z=3,4");
    assertEquals(parser.path(), "/hello");
    assertEquals(parser.params().get("recipient").get(0), "world");
    assertEquals(parser.params().get("x").get(0), "1");
    assertEquals(parser.params().get("y").get(0), "2");
    assertEquals(parser.params().get("z").get(0), "3,4");
  }
}
