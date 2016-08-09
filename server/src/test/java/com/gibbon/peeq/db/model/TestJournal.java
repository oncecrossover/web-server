package com.gibbon.peeq.db.model;

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
import com.gibbon.peeq.db.model.Journal.JournalType;
import com.gibbon.peeq.db.util.HibernateTestUtil;

public class TestJournal {
  private static final Logger LOG = LoggerFactory.getLogger(TestJournal.class);
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomJournalToJason() throws IOException {
    verifyObjectJason(newRandomInstance());
  }

  @Test(timeout = 60000)
  public void testJournalToJason() throws IOException {
    verifyObjectJason(newInstance());
  }

  private void verifyObjectJason(Object originalInstance) throws IOException {
    final ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    final String originalInstanceJson = mapper
        .writeValueAsString(originalInstance);
    LOG.info(originalInstanceJson);

    // convert json to object
    final Journal newInstance = mapper.readValue(originalInstanceJson,
        Journal.class);
    final String newInstanceJson = mapper.writeValueAsString(newInstance);
    LOG.info(newInstanceJson);
    assertEquals(originalInstanceJson, newInstanceJson);
    assertEquals(originalInstance, newInstance);
  }

  public static Journal newRandomInstance() {
    final Journal result = new Journal();
    result.setId(random.nextLong())
          .setTransactionId(random.nextLong())
          .setUid(UUID.randomUUID().toString())
          .setAmount(random.nextDouble())
          .setType(JournalType.BALANCE.toString());
    return result;
  }

  private Object newInstance() {
    final Journal result = new Journal();
    result.setId(random.nextLong())
          .setTransactionId(random.nextLong())
          .setUid("edmuand")
          .setAmount(-199)
          .setType(JournalType.BALANCE.toString());
    return result;
  }

  @Test(timeout = 60000)
  public void testCreateRecord() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;
    Journal retInstance = null;

    /* insert QaTransaction */
    final QaTransaction qaTransaction = TestQaTransaction
        .insertRandomQaTransanction();

    /* insert user */
    final User randomUser = TestUser.insertRandomUser();

    final Journal randomInstance = newRandomInstance();
    randomInstance.setTransactionId(qaTransaction.getId())
                  .setUid(randomUser.getUid());

    /* insert */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(randomInstance);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (Journal) session.get(Journal.class, randomInstance.getId());
    txn.commit();

    /* verify */
    assertEquals(randomInstance, retInstance);
  }
}