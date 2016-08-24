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

public class TestTempPwd {
  private static final Logger LOG = LoggerFactory.getLogger(TestTempPwd.class);
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testRandomTempPwdToJason() throws IOException {
    verifyTempPwdJason(newRandomInstance());
  }

  @Test(timeout = 60000)
  public void testTempPwdToJason() throws IOException {
    verifyTempPwdJason(newInstance());
  }


  private void verifyTempPwdJason(Object originalTempPwd) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalTempPwdJson = mapper.writeValueAsString(originalTempPwd);
    LOG.info(originalTempPwdJson);

    // convert json to object
    TempPwd newInstance = mapper.readValue(originalTempPwdJson, TempPwd.class);
    String newTempPwdJson = mapper.writeValueAsString(newInstance);
    LOG.info(newTempPwdJson);
    assertEquals(originalTempPwdJson, newTempPwdJson);
    originalTempPwd.equals(newInstance);
  }

  public static TempPwd newRandomInstance() {
    TempPwd tempPwd = new TempPwd();
    tempPwd.setId(random.nextLong())
           .setUid(UUID.randomUUID().toString())
           .setPwd(UUID.randomUUID().toString())
           .setStatus(TempPwd.Status.PENDING.value());
    return tempPwd;
  }

  static TempPwd newInstance() {
    TempPwd tempPwd = new TempPwd();
    tempPwd.setId(random.nextLong())
           .setUid("kuan")
           .setPwd("123456")
           .setStatus(TempPwd.Status.PENDING.value());
    return tempPwd;
  }

  @Test(timeout = 60000)
  public void testCreateTempPwd() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;

    /* insert user */
    final User user = TestUser.insertRandomUser();

    final TempPwd tempPwd = newRandomInstance();
    tempPwd.setUid(user.getUid())
           .setPwd("123456")
           .setStatus(TempPwd.Status.PENDING.value());

    /* insert */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(tempPwd);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    final TempPwd result = (TempPwd) session.get(TempPwd.class, tempPwd.getId());
    txn.commit();

    /* verify */
    assertTrue(tempPwd.equals(result));
  }

  @Test(timeout = 60000)
  public void testUpdateTempPwd() throws JsonProcessingException {
    Session session = null;
    Transaction txn = null;

    /* insert user */
    final User user = TestUser.insertRandomUser();

    final TempPwd tempPwd = newRandomInstance();
    tempPwd.setUid(user.getUid())
           .setPwd("123456")
           .setStatus(TempPwd.Status.PENDING.value());

    /* insert */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(tempPwd);
    txn.commit();

    TempPwd result;

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    result = (TempPwd) session.get(TempPwd.class, tempPwd.getId());
    txn.commit();

    /* verify */
    assertTrue(tempPwd.equals(result));

    /* change value */
    tempPwd.setPwd("456789");

    /* update */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.update(tempPwd);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    result = (TempPwd) session.get(TempPwd.class, tempPwd.getId());
    txn.commit();

    /* verify */
    assertTrue(tempPwd.equals(result));
  }
}
