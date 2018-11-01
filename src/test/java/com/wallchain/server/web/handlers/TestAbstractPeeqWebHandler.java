package com.wallchain.server.web.handlers;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import com.wallchain.server.web.handlers.AbastractWebHandler;

public class TestAbstractPeeqWebHandler {

  @Test(timeout = 60000)
  public void testToIdJson() {

    String json;

    final long lval = 10;
    json = AbastractWebHandler.toIdJson("id", lval);
    assertEquals(String.format("{\"%s\":\"%d\"}", "id", lval), json);

    final int ival = 100;
    json = AbastractWebHandler.toIdJson("id", ival);
    assertEquals(String.format("{\"%s\":\"%d\"}", "id", ival), json);

    final String sval = "garfieldo@test.com";
    json = AbastractWebHandler.toIdJson("id", sval);
    assertEquals(String.format("{\"%s\":\"%s\"}", "id", sval), json);

    final double dval = 11.1;
    json = AbastractWebHandler.toIdJson("id", dval);
    assertEquals(null, json);
  }
}
