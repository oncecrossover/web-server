package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import org.junit.Test;

public class TestQueryParamsParser {
  @Test(timeout = 60000)
  public void testParserSingleParam() {
    QueryParamsParser parser = new QueryParamsParser("/hello?recipient=world");
    assertEquals("/hello", parser.path());
    assertEquals("world", parser.param("recipient"));
    assertEquals(parser.paramCount(), 1);
  }

  @Test(timeout = 60000)
  public void testParserWithPath() {
    QueryParamsParser parser = new QueryParamsParser(
        "/hello?recipient=world&x=1;y=2");
    assertEquals("/hello", parser.path());
    assertEquals("world", parser.param("recipient"));
    assertEquals("1", parser.param("x"));
    assertEquals("2", parser.param("y"));
    assertEquals(parser.paramCount(), 3);
  }

  @Test(timeout = 60000)
  public void testParserWithoutPath() {
    QueryParamsParser parser = new QueryParamsParser(
        "recipient=world&x=1;y=2",
        false);
    assertEquals("", parser.path());
    assertEquals("world", parser.param("recipient"));
    assertEquals("1", parser.param("x"));
    assertEquals("2", parser.param("y"));
    assertEquals(parser.paramCount(), 3);
  }

  @Test(timeout = 60000)
  public void testParserWithValueList() {
    QueryParamsParser parser = new QueryParamsParser(
        "/hello?recipient=world&x=1;y=2&z=3&z=4");
    assertEquals("/hello", parser.path());
    assertEquals("world", parser.param("recipient"));
    assertEquals("1", parser.param("x"));
    assertEquals("2", parser.param("y"));
    assertEquals("3", parser.params("z").get(0));
    assertEquals("4", parser.params("z").get(1));
    assertEquals(parser.paramCount(), 4);
  }

  @Test(timeout = 60000)
  public void testParserFilterPaginationOrder() {
    final String uri = "/hello?id=1&uid=edmund@gmail.com&createdTime="
        + "'2016-08-27 18:35:54'&quandaId=10&offset=5&limit=25"
        + "&sort=uid&sort=quandaId&sort='createdTime desc'";
    QueryParamsParser parser = new QueryParamsParser(uri);
    assertEquals("1", parser.param("id"));
    assertEquals("edmund@gmail.com", parser.param("uid"));
    assertEquals("'2016-08-27 18:35:54'", parser.param("createdTime"));
    assertEquals("10", parser.param("quandaId"));
    assertEquals("5", parser.param("offset"));
    assertEquals("25", parser.param("limit"));
    assertEquals("uid", parser.params("sort").get(0));
    assertEquals("quandaId", parser.params("sort").get(1));
    assertEquals("'createdTime desc'", parser.params("sort").get(2));
    assertEquals(0, parser.params("xxx").size());
    assertEquals(null, parser.param("xxx"));
    assertEquals(parser.paramCount(), 7);
  }
}
