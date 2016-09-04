package com.gibbon.peeq.db.model;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.util.UUID;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.model.PwdEntry;

public class TestPwdEntry {
  private static final Logger LOG = LoggerFactory.getLogger(TestPwdEntry.class);

  @Test(timeout = 60000)
  public void testRandomInstanceToJason() throws IOException {
    verifyPwdEntryJason(newRandomInstance());
  }

  @Test(timeout = 60000)
  public void testInstanceToJason() throws IOException {
    verifyPwdEntryJason(newInstance());
  }


  private void verifyPwdEntryJason(Object originalPwdEntry) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalPwdEntryJson = mapper.writeValueAsString(originalPwdEntry);
    LOG.info(originalPwdEntryJson);

    // convert json to object
    PwdEntry newInstance = mapper.readValue(originalPwdEntryJson, PwdEntry.class);
    String newPwdEntryJson = mapper.writeValueAsString(newInstance);
    LOG.info(newPwdEntryJson);
    assertEquals(originalPwdEntryJson, newPwdEntryJson);
    originalPwdEntry.equals(newInstance);
  }

  public static PwdEntry newRandomInstance() {
    PwdEntry instance = new PwdEntry();
    instance.setUid(UUID.randomUUID().toString())
            .setTempPwd(UUID.randomUUID().toString())
            .setNewPwd(UUID.randomUUID().toString());
    return instance;
  }

  static PwdEntry newInstance() {
    PwdEntry instance = new PwdEntry();
    instance.setUid(UUID.randomUUID().toString())
            .setTempPwd("_PbW%o")
            .setNewPwd("helllopwd");
    return instance;
  }
}
