package com.gibbon.peeq.db.model;

import static org.junit.Assert.*;

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

public class TestQuanda {
  private static final Logger LOG = LoggerFactory.getLogger(TestQuanda.class);
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomQuandaToJason() throws IOException {
    verifyQuandaJason(newRandomQuanda());
  }

  @Test(timeout = 60000)
  public void testQuandaToJason() throws IOException {
    verifyQuandaJason(newQuanda());
  }

  private Quanda newQuanda() {
    Quanda quanda = new Quanda();
    quanda.setId(random.nextLong())
          .setAsker("kuan")
          .setQuestion("How do you define good man?")
          .setResponder("edmund")
          .setAnswerAudio("This is answer audio.".getBytes())
          .setStatus(Quanda.QnaStatus.ANSWERED.toString());
    return quanda;
  }

  private Quanda newRandomQuanda() {
    Quanda quanda = new Quanda();
    quanda.setId(random.nextLong())
          .setAsker(UUID.randomUUID().toString())
          .setQuestion(UUID.randomUUID().toString())
          .setResponder(UUID.randomUUID().toString())
          .setAnswerAudio("This is random answer audio.".getBytes())
          .setStatus(Quanda.QnaStatus.PENDING.toString());
    return quanda;
  }

  private void verifyQuandaJason(final Quanda originalQuanda) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalQuandaJson = mapper.writeValueAsString(originalQuanda);
    LOG.info(originalQuandaJson);

    // convert json to object
    Quanda newQuanda = mapper.readValue(originalQuandaJson, Quanda.class);
    String newQuandaJson = mapper.writeValueAsString(newQuanda);
    LOG.info(newQuandaJson);
    assertEquals(originalQuandaJson, newQuandaJson);
    originalQuanda.equals(newQuanda);
  }


  private User insertRandomUser() {
    final User user = TestUser.newRandomUser();
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();
    Transaction txn = session.beginTransaction();
    session.save(user);
    txn.commit();
    return user;
  }

  @Test(timeout = 60000)
  public void testCreateQuanda() throws JsonProcessingException {
    final Quanda quanda = newRandomQuanda();
    Session session = null;
    Transaction txn = null;
    User user = null;
    User anotherUser = null;

    /* insert user */
    user = insertRandomUser();

    /* insert another user */
    anotherUser = insertRandomUser();

    /* set asker and responder */
    quanda.setAsker(user.getUid())
          .setResponder(anotherUser.getUid());

    /* insert quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(quanda);
    txn.commit();

    /* query quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    final Quanda retQuanda = (Quanda) session.get(Quanda.class, quanda.getId());
    txn.commit();

    /* verify */
    assertTrue(quanda.equals(retQuanda));
  }

  @Test(timeout = 60000)
  public void testDeleteQuanda() throws JsonProcessingException {
    final Quanda quanda = newRandomQuanda();
    Session session = null;
    Transaction txn = null;
    User user = null;
    User anotherUser = null;
    Quanda retQuanda = null;

    /* insert user */
    user = insertRandomUser();

    /* insert another user */
    anotherUser = insertRandomUser();

    /* set asker and responder */
    quanda.setAsker(user.getUid())
          .setResponder(anotherUser.getUid());

    /* insert quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(quanda);
    txn.commit();

    /* query quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retQuanda = (Quanda) session.get(Quanda.class, quanda.getId());
    txn.commit();

    /* verify */
    assertTrue(quanda.equals(retQuanda));

    /* delete quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.delete(quanda);
    txn.commit();

    /* query... */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retQuanda = (Quanda) session.get(Quanda.class, quanda.getId());
    txn.commit();

    /* verify */
    assertEquals(null, retQuanda);
  }

  @Test(timeout = 60000)
  public void testUpdateQuanda() throws JsonProcessingException {
    final Quanda quanda = newRandomQuanda();
    Session session = null;
    Transaction txn = null;
    User user = null;
    User anotherUser = null;
    Quanda retQuanda = null;

    /* insert user */
    user = insertRandomUser();

    /* insert another user */
    anotherUser = insertRandomUser();

    /* assign asker and responder */
    quanda.setAsker(user.getUid())
          .setResponder(anotherUser.getUid());

    /* insert quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(quanda);
    txn.commit();

    /* query quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retQuanda = (Quanda) session.get(Quanda.class, quanda.getId());
    txn.commit();

    /* verify */
    quanda.equals(retQuanda);

    /* set something new */
    quanda.setAsker(UUID.randomUUID().toString())
          .setResponder(UUID.randomUUID().toString());

    /* update quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.delete(quanda);
    txn.commit();

    /* query... */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retQuanda = (Quanda) session.get(Quanda.class, quanda.getId());
    txn.commit();

    /* verify */
    quanda.equals(retQuanda);
  }
}
