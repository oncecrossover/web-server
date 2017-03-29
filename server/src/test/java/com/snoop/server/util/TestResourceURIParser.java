package com.snoop.server.util;

import static org.junit.Assert.*;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.snoop.server.util.ResourcePathParser;

public class TestResourceURIParser {
  private static final Logger LOG = LoggerFactory
      .getLogger(TestResourceURIParser.class);

  @Test(timeout = 60000)
  public void testPathStreamBasic() {
    String uri;
    ResourcePathParser rpp = null;

    uri = "/profiles?filter=*";
    rpp = new ResourcePathParser(uri);
    assertEquals("profiles", rpp.getPathStream().nextToken());
    assertEquals(false, rpp.getPathStream().hasNext());

    uri = "/profiles?filter=uid=edmund";
    rpp = new ResourcePathParser(uri);
    assertEquals("profiles", rpp.getPathStream().nextToken());
    assertEquals(false, rpp.getPathStream().hasNext());
  }

  @Test(timeout = 60000)
  public void testPathStreamRecursion() {
    final String uri = "/users/edmund/quandas";
    ResourcePathParser rpp = null;
    int index = -1;
    rpp = new ResourcePathParser(uri);

    assertEquals("users", rpp.getPathStream().nextToken());
    index = rpp.getPathStream().getTouchedIndex();
    assertEquals(index, 0);
    assertEquals("edmund", rpp.getPathStream().nextToken());
    index = rpp.getPathStream().getTouchedIndex();
    assertEquals(index, 1);
    assertEquals("quandas", rpp.getPathStream().nextToken());
    index = rpp.getPathStream().getTouchedIndex();
    assertEquals(index, 2);
    assertEquals(false, rpp.getPathStream().hasNext());
  }

  @Test(timeout = 60000)
  public void testPathStreamNextIndex() {
    final String uri = "/users/edmund/quandas";
    ResourcePathParser rpp = null;
    rpp = new ResourcePathParser(uri);

    assertEquals("users", rpp.getPathStream().nextToken());

    // start from here...
    assertEquals("edmund", rpp.getPathStream().nextToken());
    int uidIndex = rpp.getPathStream().getTouchedIndex();
    assertEquals(uidIndex, 1);

    int quandasIndex = rpp.getPathStream().nextIndex();
    assertEquals(quandasIndex, 2);
    assertEquals("quandas", rpp.getPathStream().nextToken());
    quandasIndex = rpp.getPathStream().getTouchedIndex();
    assertEquals(quandasIndex, 2);
  }


  @Test(timeout = 60000)
  public void testPathStreamBacktrack() {
    final String uri = "/users/edmund/quandas";
    ResourcePathParser rpp = null;
    rpp = new ResourcePathParser(uri);

    assertEquals("users", rpp.getPathStream().nextToken());
    int uidIndex = rpp.getPathStream().nextIndex();
    assertEquals(uidIndex, 1);
    assertEquals("edmund", rpp.getPathStream().nextToken());
    assertEquals("quandas", rpp.getPathStream().nextToken());

    /* reset to start over from index 0*/
    rpp.getPathStream().reset();

    // move pointer to 'edmund'
    rpp.getPathStream().pointTo(uidIndex);
    assertEquals("edmund", rpp.getPathStream().nextToken());
    assertEquals("quandas", rpp.getPathStream().nextToken());
  }
}
