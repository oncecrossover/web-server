package com.gibbon.peeq.db.model;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.util.Random;
import java.util.UUID;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.databind.ObjectMapper;

public class TestBalance {
  private static final Logger LOG = LoggerFactory.getLogger(TestBalance.class);
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomBalanceToJason() throws IOException {
    verifyBalanceJason(newRandomBalance());
  }

  @Test(timeout = 60000)
  public void testBalanceToJason() throws IOException {
    verifyBalanceJason(newBalance());
  }

  private static Balance newRandomBalance() {
    final Balance balance = new Balance();
    balance.setUid(UUID.randomUUID().toString())
           .setVal(random.nextLong());
    return balance;
  }

  private static Balance newBalance() {
    final Balance balance = new Balance();
    balance.setUid("kuan");
    balance.setVal(100);
    return balance;
  }

  @Test(timeout = 60000)
  public void testCreateBalanceFromJson() throws IOException {
    final String json = "{\"uid\":\"edmund\",\"val\":100}";

    ObjectMapper mapper = new ObjectMapper();

    // convert json to object
    Balance balance = mapper.readValue(json, Balance.class);
    verifyBalanceJason(balance);
  }

  private void verifyBalanceJason(final Balance originalBalance) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalBalanceJson = mapper.writeValueAsString(originalBalance);
    LOG.info(originalBalanceJson);

    // convert json to object
    final Balance newBalance = mapper.readValue(originalBalanceJson, Balance.class);
    final String newBalanceJson = mapper.writeValueAsString(newBalance);
    LOG.info(newBalanceJson);
    assertEquals(originalBalanceJson, newBalanceJson);
    originalBalance.equals(newBalance);
  }
}
