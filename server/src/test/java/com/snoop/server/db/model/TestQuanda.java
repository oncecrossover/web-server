package com.snoop.server.db.model;

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
import com.snoop.server.db.model.Quanda;
import com.snoop.server.db.model.User;
import com.snoop.server.db.util.HibernateTestUtil;

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
          .setAnswerMedia("This is answer media.".getBytes())
          .setAnswerCover("This is answer cover.".getBytes())
          .setStatus(Quanda.QnaStatus.ANSWERED.toString())
          .setActive(Quanda.LiveStatus.TRUE.value())
          .setRate(random.nextInt())
          .setCreatedTime(new Date())
          .setUpdatedTime(new Date());
    return quanda;
  }

  static Quanda newRandomQuanda() {
    Quanda quanda = new Quanda();
    quanda.setId(random.nextLong())
          .setAsker(UUID.randomUUID().toString())
          .setQuestion(UUID.randomUUID().toString())
          .setResponder(UUID.randomUUID().toString())
          .setAnswerMedia("This is random answer media.".getBytes())
          .setAnswerCover("This is random answer cover.".getBytes())
          .setStatus(Quanda.QnaStatus.PENDING.toString())
          .setActive(Quanda.LiveStatus.TRUE.value())
          .setRate(random.nextInt())
          .setCreatedTime(new Date())
          .setUpdatedTime(new Date());
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

  @Test(timeout = 60000)
  public void testCreateQuanda() throws JsonProcessingException {
    final Quanda quanda = newRandomQuanda();
    insertRandomQuanda(quanda);
  }

  public static Quanda insertRandomQuanda() throws JsonProcessingException {
    final Quanda quanda = newRandomQuanda();
    return insertRandomQuanda(quanda);
  }

  public static Quanda insertRandomQuanda(final Quanda quanda)
      throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;
    User user = null;
    User anotherUser = null;

    /* insert user */
    user = TestUser.insertRandomUser();

    /* insert another user */
    anotherUser = TestUser.insertRandomUser();

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
    return quanda;
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
    user = TestUser.insertRandomUser();

    /* insert another user */
    anotherUser = TestUser.insertRandomUser();

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
    assertEquals(quanda, retQuanda);

    /* set something new */
    quanda.setAsker(UUID.randomUUID().toString())
          .setResponder(UUID.randomUUID().toString());

    /* update quanda */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.update(quanda);
    txn.commit();

    /* query... */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retQuanda = (Quanda) session.get(Quanda.class, quanda.getId());
    txn.commit();

    /* verify */
    assertEquals(quanda, retQuanda);
  }
}
