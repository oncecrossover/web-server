package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestResourceURIParser {
  private static final Logger LOG = LoggerFactory
      .getLogger(TestResourceURIParser.class);

  @Test(timeout = 60000)
  public void testPathStream() {
    String uri = "/profiles?filter=*";
    ResourceURIParser rup = null;

    uri = "/profiles?filter=*";
    rup = new ResourceURIParser(uri);
    assertEquals("profiles", rup.getPathStream().next());
    assertEquals(false, rup.getPathStream().hasNext());

    uri = "/profiles?filter=uid=edmund";
    rup = new ResourceURIParser(uri);
    assertEquals("profiles", rup.getPathStream().next());
    assertEquals(false, rup.getPathStream().hasNext());
  }
}
