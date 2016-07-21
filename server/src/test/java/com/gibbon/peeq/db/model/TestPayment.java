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
import com.gibbon.peeq.db.model.Payment.PaymentType;
import com.gibbon.peeq.db.util.HibernateTestUtil;

public class TestPayment {
  private static final Logger LOG = LoggerFactory.getLogger(TestPayment.class);
  private static Random random = new Random(System.currentTimeMillis());


  @Test(timeout = 60000)
  public void testRandomPaymentToJason() throws IOException {
    verifyPaymentJason(newRandomPayment());
  }

  @Test(timeout = 60000)
  public void testPaymentToJason() throws IOException {
    verifyPaymentJason(newPayment());
  }

  private static Payment newRandomPayment() {
    final Payment payment = new Payment();
    payment.setId(random.nextLong())
           .setUid(UUID.randomUUID().toString())
           .setAccId(UUID.randomUUID().toString())
           .setType(PaymentType.CARD.toString())
           .setLastFour(UUID.randomUUID().toString())
           .setToken(UUID.randomUUID().toString());
    return payment;
  }

  private static Payment newPayment() {
    final Payment payment = new Payment();
    payment.setId(random.nextLong())
           .setUid("kuan")
           .setAccId("this_is_my_acc_id")
           .setType(PaymentType.CARD.toString())
           .setLastFour("1234")
           .setToken(UUID.randomUUID().toString());
    return payment;
  }

  private void verifyPaymentJason(final Payment originalPayment) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalPaymentJson = mapper.writeValueAsString(originalPayment);
    LOG.info(originalPaymentJson);

    // convert json to object
    final Payment newPayment = mapper.readValue(originalPaymentJson, Payment.class);
    final String newPaymentJson = mapper.writeValueAsString(newPayment);
    LOG.info(newPaymentJson);
    assertEquals(originalPaymentJson, newPaymentJson);
    originalPayment.equals(newPayment);
  }

  @Test(timeout = 60000)
  public void testCreatePayment() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;

    final Payment payment = newRandomPayment();
    payment.setCreatedTime(new Date());

    /* insert user */
    final User user = TestQuanda.insertRandomUser();

    /* set user */
    payment.setUid(user.getUid());

    /* insert payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(payment);
    txn.commit();

    /* query payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    final Payment retPayment = (Payment) session.get(Payment.class, payment.getId());
    txn.commit();

    /* verify */
    assertTrue(payment.equals(retPayment));
  }

  @Test(timeout = 60000)
  public void testDeletePayment() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;
    Payment retPayment = null;

    final Payment payment = newRandomPayment();
    payment.setCreatedTime(new Date());

    /* insert user */
    final User user = TestQuanda.insertRandomUser();

    /* set user */
    payment.setUid(user.getUid());

    /* insert payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(payment);
    txn.commit();

    /* query payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retPayment = (Payment) session.get(Payment.class, payment.getId());
    txn.commit();

    /* verify */
    assertTrue(payment.equals(retPayment));

    /* delete payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.delete(payment);
    txn.commit();

    /* query... */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retPayment = (Payment) session.get(Payment.class, payment.getId());
    txn.commit();

    /* verify */
    assertEquals(null, retPayment);
  }

  @Test(timeout = 60000)
  public void testUpdatePayment() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;
    Payment retPayment = null;

    final Payment payment = newRandomPayment();
    payment.setCreatedTime(new Date());

    /* insert user */
    final User user = TestQuanda.insertRandomUser();

    /* set user */
    payment.setUid(user.getUid());

    /* insert payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(payment);
    txn.commit();

    /* query payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retPayment = (Payment) session.get(Payment.class, payment.getId());
    txn.commit();

    /* verify */
    assertEquals(payment, retPayment);

    /* set something new */
    payment.setUid(UUID.randomUUID().toString());

    /* update payment */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.update(payment);
    txn.commit();

    /* query... */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retPayment = (Payment) session.get(Payment.class, payment.getId());
    txn.commit();

    /* verify */
    assertEquals(payment, retPayment);
  }
}
