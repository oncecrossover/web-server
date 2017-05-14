package com.snoop.server.db.model;

import java.io.IOException;
import java.util.Random;
import java.util.UUID;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.junit.Assert.assertEquals;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.snoop.server.db.model.PcAccount;

public class TestPcAccount {
  private static final Logger LOG = LoggerFactory
      .getLogger(TestPcAccount.class);
  private static Random r = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomPcAccountToJason() throws IOException {
    verifyPcAccountJason(newRandomPcAccount());
  }

  @Test(timeout = 60000)
  public void testPcAccountToJason() throws IOException {
    verifyPcAccountJason(newPcAccount());
  }

  @Test(timeout = 60000)
  public void testCreateFromJson()
      throws JsonParseException, JsonMappingException, IOException {
    final String json = "{\"id\":123,\"chargeFrom\":\"this_is_my_charge_from_account\",\"payTo\":\"this_is_my_pay_to_account\",\"createdTime\":null,\"updatedTime\":null}";
    ObjectMapper mapper = new ObjectMapper();

    // convert json to object
    final PcAccount result = mapper.readValue(json, PcAccount.class);
    verifyPcAccountJason(result);
  }

  private static PcAccount newRandomPcAccount() {
    final PcAccount result = new PcAccount();
    result.setId(r.nextLong())
        .setChargeFrom(UUID.randomUUID().toString())
        .setPayTo(UUID.randomUUID().toString());
    return result;
  }

  private static PcAccount newPcAccount() {
    final PcAccount result = new PcAccount();
    result.setId(r.nextLong()).setChargeFrom("this_is_my_charge_from_account")
        .setPayTo("this_is_my_pay_to_account");
    return result;
  }

  private void verifyPcAccountJason(final PcAccount originalInstance)
      throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    final String originalInstanceJson = mapper
        .writeValueAsString(originalInstance);
    LOG.info(originalInstanceJson);

    // convert json to object
    final PcAccount newInstance = mapper.readValue(originalInstanceJson,
        PcAccount.class);
    final String newInstanceJson = mapper.writeValueAsString(newInstance);
    LOG.info(newInstanceJson);
    assertEquals(originalInstanceJson, newInstanceJson);
    originalInstance.equals(newInstance);
  }
}
