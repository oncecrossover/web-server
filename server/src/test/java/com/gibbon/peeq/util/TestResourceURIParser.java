package com.gibbon.peeq.util;

import static org.junit.Assert.*;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestResourceURIParser {
  private static final Logger LOG = LoggerFactory
      .getLogger(TestResourceURIParser.class);

  @Test(timeout = 60000)
  public void testPathStreamBasic() {
    String uri = "/profiles?filter=*";
    ResourceURIParser rup = null;

    uri = "/profiles?filter=*";
    rup = new ResourceURIParser(uri);
    assertEquals("profiles", rup.getPathStream().nextToken());
    assertEquals(false, rup.getPathStream().hasNext());

    uri = "/profiles?filter=uid=edmund";
    rup = new ResourceURIParser(uri);
    assertEquals("profiles", rup.getPathStream().nextToken());
    assertEquals(false, rup.getPathStream().hasNext());
  }

  @Test(timeout = 60000)
  public void testPathStreamRecursion() {
    final String uri = "/users/edmund/quandas";
    ResourceURIParser rup = null;
    int index = -1;
    rup = new ResourceURIParser(uri);

    assertEquals("users", rup.getPathStream().nextToken());
    index = rup.getPathStream().getTouchedIndex();
    assertEquals(index, 0);
    assertEquals("edmund", rup.getPathStream().nextToken());
    index = rup.getPathStream().getTouchedIndex();
    assertEquals(index, 1);
    assertEquals("quandas", rup.getPathStream().nextToken());
    index = rup.getPathStream().getTouchedIndex();
    assertEquals(index, 2);
  }

  @Test(timeout = 60000)
  public void testPathStreamNextIndex() {
    final String uri = "/users/edmund/quandas";
    ResourceURIParser rup = null;
    rup = new ResourceURIParser(uri);

    assertEquals("users", rup.getPathStream().nextToken());

    // start from here...
    assertEquals("edmund", rup.getPathStream().nextToken());
    int uidIndex = rup.getPathStream().getTouchedIndex();
    assertEquals(uidIndex, 1);

    int quandasIndex = rup.getPathStream().nextIndex();
    assertEquals(quandasIndex, 2);
    assertEquals("quandas", rup.getPathStream().nextToken());
    quandasIndex = rup.getPathStream().getTouchedIndex();
    assertEquals(quandasIndex, 2);
  }


  @Test(timeout = 60000)
  public void testPathStreamBacktrack() {
    final String uri = "/users/edmund/quandas";
    ResourceURIParser rup = null;
    rup = new ResourceURIParser(uri);

    assertEquals("users", rup.getPathStream().nextToken());
    int uidIndex = rup.getPathStream().nextIndex();
    assertEquals(uidIndex, 1);
    assertEquals("edmund", rup.getPathStream().nextToken());
    assertEquals("quandas", rup.getPathStream().nextToken());

    /* reset to start over from index 0*/
    rup.getPathStream().reset();

    // move pointer to 'edmund'
    rup.getPathStream().pointTo(uidIndex);
    assertEquals("edmund", rup.getPathStream().nextToken());
    assertEquals("quandas", rup.getPathStream().nextToken());
  }
}
