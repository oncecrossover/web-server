package com.gibbon.peeq.db.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.util.Date;
import java.util.Random;
import java.util.UUID;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.db.util.HibernateTestUtil;

public class TestSnoop {
  private static final Logger LOG = LoggerFactory.getLogger(TestSnoop.class);
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomSnoopToJason() throws IOException {
    verifySnoopJason(newRandomSnoop());
  }

  @Test(timeout = 60000)
  public void testSnoopToJason() throws IOException {
    verifySnoopJason(newSnoop());
  }


  private void verifySnoopJason(Object originalSnoop) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalSnoopJson = mapper.writeValueAsString(originalSnoop);
    LOG.info(originalSnoopJson);

    // convert json to object
    Snoop newSnoop = mapper.readValue(originalSnoopJson, Snoop.class);
    String newSnoopJson = mapper.writeValueAsString(newSnoop);
    LOG.info(newSnoopJson);
    assertEquals(originalSnoopJson, newSnoopJson);
    originalSnoop.equals(newSnoop);
  }

  private Snoop newRandomSnoop() {
    Snoop snoop = new Snoop();
    snoop.setId(random.nextLong())
         .setUid(UUID.randomUUID().toString())
         .setQuandaId(random.nextLong())
         .setCreatedTime(new Date());
    return snoop;
  }

  private Object newSnoop() {
    Snoop snoop = new Snoop();
    snoop.setId(random.nextLong())
         .setUid("kuan")
         .setQuandaId(1)
         .setCreatedTime(new Date());
    return snoop;
  }

  @Test(timeout = 60000)
  public void testCreateSnoop() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;

    /* insert user */
    final User user = TestUser.insertRandomUser();

    /* insert quanda */
    final Quanda quanda = TestQuanda.newRandomQuanda();
    TestQuanda.testCreateQuanda(quanda);

    final Snoop snoop = newRandomSnoop();
    snoop.setUid(user.getUid())
         .setQuandaId(quanda.getId())
         .setCreatedTime(new Date());

    /* insert snoop */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(snoop);
    txn.commit();

    /* query snoop */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    final Snoop result = (Snoop) session.get(Snoop.class, snoop.getId());
    txn.commit();

    /* verify */
    assertTrue(snoop.equals(result));
  }
}
