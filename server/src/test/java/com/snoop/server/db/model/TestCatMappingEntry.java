package com.snoop.server.db.model;

import static org.junit.Assert.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.text.StrBuilder;
import org.junit.Test;
import org.mortbay.log.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.snoop.server.db.model.CatMappingEntry;
import com.snoop.server.db.model.ModelBase;

public class TestCatMappingEntry {

  private static final Logger LOG = LoggerFactory
      .getLogger(TestCatMappingEntry.class);

  private static final String JSON_STR = "[{\"id\":null,\"catId\":\"1\",\"catName\":null,\"catDescription\":null,\"uid\":\"123\",\"isExpertise\":\"YES\",\"isInterest\":null,\"createdTime\":null,\"updatedTime\":null},{\"id\":null,\"catId\":\"2\",\"catName\":null,\"catDescription\":null,\"uid\":\"345\",\"isExpertise\":\"YES\",\"isInterest\":null,\"createdTime\":null,\"updatedTime\":null}]";

  @Test(timeout = 60000)
  public void testDeserializeJson()
      throws JsonParseException, JsonMappingException, IOException {
    List<CatMappingEntry> list = ModelBase.newInstanceAsList(
        JSON_STR,
        CatMappingEntry.class);
    LOG.info(JSON_STR);
    LOG.info(listToJsonString(list));
    assertEquals(JSON_STR, listToJsonString(list));
  }

  @Test(timeout = 60000)
  public void testSerializeJson() {
    final List<CatMappingEntry> list = Lists.newArrayList();
    CatMappingEntry entry = null;
    entry = new CatMappingEntry().setCatId(1L).setUid(123L)
        .setIsExpertise(CatMappingEntry.Status.YES.value());
    list.add(entry);
    entry = new CatMappingEntry().setCatId(2L).setUid(345L)
        .setIsExpertise(CatMappingEntry.Status.YES.value());
    list.add(entry);

    LOG.info(JSON_STR);
    LOG.info(listToJsonString(list));
    assertEquals(JSON_STR, listToJsonString(list));
  }

  <T> String listToJsonString(final List<T> list) {
    /* build json */
    final StrBuilder sb = new StrBuilder();
    sb.append("[");
    if (list != null) {
      sb.append(Joiner.on(",").skipNulls().join(list));
    }
    sb.append("]");
    return sb.toString();
  }
}
