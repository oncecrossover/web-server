package com.gibbon.peeq.handlers;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class TestAbstractPeeqWebHandler {

  @Test(timeout = 60000)
  public void testToIdJson() {

    String json;

    final long lval = 10;
    json = AbastractPeeqWebHandler.toIdJson("id", lval);
    assertEquals(String.format("{\"%s\":%d}", "id", lval), json);

    final int ival = 100;
    json = AbastractPeeqWebHandler.toIdJson("id", ival);
    assertEquals(String.format("{\"%s\":%d}", "id", ival), json);

    final String sval = "garfieldo@test.com";
    json = AbastractPeeqWebHandler.toIdJson("id", sval);
    assertEquals(String.format("{\"%s\":\"%s\"}", "id", sval), json);

    final double dval = 11.1;
    json = AbastractPeeqWebHandler.toIdJson("id", dval);
    assertEquals(null, json);
  }
}
