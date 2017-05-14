package com.snoop.server.db.model;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.util.Random;
import java.util.UUID;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.snoop.server.db.model.PcEntry;
import com.snoop.server.db.model.User;
import com.snoop.server.db.util.HibernateTestUtil;

public class TestPcEntry {
  private static final Logger LOG = LoggerFactory.getLogger(TestPcEntry.class);
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomPcEntryToJason() throws IOException {
    verifyObjectJason(newRandomInstance());
  }

  @Test(timeout = 60000)
  public void testPcEntryToJason() throws IOException {
    verifyObjectJason(newInstance());
  }


  private void verifyObjectJason(Object originalInstance) throws IOException {
    final ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    final String originalInstanceJson = mapper.writeValueAsString(originalInstance);
    LOG.info(originalInstanceJson);

    // convert json to object
    final PcEntry newInstance = mapper.readValue(originalInstanceJson, PcEntry.class);
    final String newInstanceJson = mapper.writeValueAsString(newInstance);
    LOG.info(newInstanceJson);
    assertEquals(originalInstanceJson, newInstanceJson);
    assertEquals(originalInstance, newInstance);
  }

  private PcEntry newRandomInstance() {
    final PcEntry result = new PcEntry();
    result.setId(random.nextLong())
          .setUid(random.nextLong())
          .setEntryId(UUID.randomUUID().toString())
          .setBrand(UUID.randomUUID().toString())
          .setLast4(UUID.randomUUID().toString())
          .setToken(UUID.randomUUID().toString());
    return result;
  }

  private Object newInstance() {
    final PcEntry result = new PcEntry();
    result.setId(random.nextLong())
          .setUid(random.nextLong())
          .setEntryId("card_12345678")
          .setBrand("VISA")
          .setLast4("5678")
          .setToken("tok_hiuahoi783JHGddhujd");
    return result;
  }

  @Test(timeout = 60000)
  public void testCreateRecord() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;
    PcEntry retInstance = null;

    /* insert user */
    final User randomUser = TestUser.insertRandomUser();

    final PcEntry randomInstance = newRandomInstance();
    randomInstance.setUid(randomUser.getId());

    /* insert */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(randomInstance);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (PcEntry) session.get(PcEntry.class,
        randomInstance.getId());
    txn.commit();

    /* verify */
    assertEquals(randomInstance, retInstance);
  }
}
