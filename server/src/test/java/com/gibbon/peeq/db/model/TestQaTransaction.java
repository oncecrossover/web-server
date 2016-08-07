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
import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.QaTransaction.TransType;
import com.gibbon.peeq.db.util.HibernateTestUtil;

public class TestQaTransaction {
  private static final Logger LOG = LoggerFactory.getLogger(TestQaTransaction.class);
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomTransactionToJason() throws IOException {
    verifyObjectJason(newRandomInstance());
  }

  @Test(timeout = 60000)
  public void testTransactionToJason() throws IOException {
    verifyObjectJason(newInstance());
  }


  private void verifyObjectJason(Object originalInstance) throws IOException {
    final ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    final String originalInstanceJson = mapper.writeValueAsString(originalInstance);
    LOG.info(originalInstanceJson);

    // convert json to object
    final QaTransaction newInstance = mapper.readValue(originalInstanceJson, QaTransaction.class);
    final String newInstanceJson = mapper.writeValueAsString(newInstance);
    LOG.info(newInstanceJson);
    assertEquals(originalInstanceJson, newInstanceJson);
    assertEquals(originalInstance, newInstance);
  }

  private static QaTransaction newRandomInstance() {
    final QaTransaction result = new QaTransaction();
    result.setId(random.nextLong())
          .setUid(UUID.randomUUID().toString())
          .setType(TransType.ASKED.toString())
          .setQuandaId(random.nextLong())
          .setAmount(random.nextDouble());
    return result;
  }

  private static Object newInstance() {
    final QaTransaction result = new QaTransaction();
    result.setId(random.nextLong())
          .setUid("edmuand")
          .setType(TransType.ASKED.toString())
          .setQuandaId(10)
          .setAmount(1000);
    return result;
  }

  static QaTransaction insertRandomQaTransanction()
      throws JsonProcessingException {
    /* insert user */
    final User randomUser = TestUser.insertRandomUser();

    /* insert quanda */
    final Quanda randomQuanda = TestQuanda.newRandomQuanda();
    TestQuanda.insertRandomQuanda(randomQuanda);

    final QaTransaction randomInstance = newRandomInstance();
    randomInstance.setUid(randomUser.getUid());
    randomInstance.setQuandaId(randomQuanda.getId());

    /* insert QaTransaction */
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();
    Transaction txn = session.beginTransaction();
    session.save(randomInstance);
    txn.commit();
    return randomInstance;
  }

  @Test(timeout = 60000)
  public void testCreateRecord() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;
    QaTransaction retInstance = null;

    /* insert user */
    final User randomUser = TestUser.insertRandomUser();

    /* insert quanda */
    final Quanda randomQuanda = TestQuanda.newRandomQuanda();
    TestQuanda.insertRandomQuanda(randomQuanda);

    final QaTransaction randomInstance = newRandomInstance();
    randomInstance.setUid(randomUser.getUid());
    randomInstance.setQuandaId(randomQuanda.getId());

    /* insert */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(randomInstance);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (QaTransaction) session.get(QaTransaction.class,
        randomInstance.getId());
    txn.commit();

    /* verify */
    assertEquals(randomInstance, retInstance);
  }

  @Test(timeout = 60000)
  public void testDeleteRecord() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;
    QaTransaction retInstance = null;

    /* insert user */
    final User randomUser = TestUser.insertRandomUser();

    final QaTransaction randomInstance = newRandomInstance();
    randomInstance.setUid(randomUser.getUid());

    /* insert */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(randomInstance);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (QaTransaction) session.get(QaTransaction.class,
        randomInstance.getId());
    txn.commit();

    /* verify */
    assertEquals(randomInstance, retInstance);

    /* delete */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.delete(retInstance);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (QaTransaction) session.get(QaTransaction.class,
        retInstance.getId());
    txn.commit();

    /* verify */
    assertEquals(null, retInstance);
  }
}
