package com.gibbon.peeq.db.util;

import static org.junit.Assert.assertEquals;

import java.util.UUID;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;

import com.gibbon.peeq.db.model.TempPwd;
import com.gibbon.peeq.db.model.TestTempPwd;
import com.gibbon.peeq.db.model.TestUser;
import com.gibbon.peeq.db.model.User;

public class TestTempPwdUtil {

  @Test(timeout = 60000)
  public void testTempPwdExists4UserWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final boolean result = TempPwdUtil.tempPwdExists4User(session,
        UUID.randomUUID().toString(), UUID.randomUUID().toString(), true);
    assertEquals(false, result);
  }

  @Test(timeout = 60000)
  public void testTempPwdExists4User() throws Exception {
    Session session = null;
    Transaction txn = null;
    TempPwd retInstance = null;
    TempPwd randomInstance = null;

    /* insert user */
    final User randomUser = TestUser.insertRandomUser();
    final String uid = randomUser.getUid();

    /* insert TempPwd */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    randomInstance = TestTempPwd.newRandomInstance();
    randomInstance.setUid(uid);
    txn = session.beginTransaction();
    session.save(randomInstance);
    txn.commit();

    /* query */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (TempPwd) session.get(TempPwd.class, randomInstance.getId());
    txn.commit();

    /* verify */
    assertEquals(randomInstance, retInstance);

    /* query pending pwd for user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();

    final boolean result = TempPwdUtil.tempPwdExists4User(session, uid,
        randomInstance.getPwd(), true);
    assertEquals(true, result);
  }

  @Test(timeout = 60000)
  public void testExpireAllPendingPwdsWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final int result = TempPwdUtil.expireAllPendingPwds(session,
        UUID.randomUUID().toString(), true);
    assertEquals(0, result);
  }

  @Test(timeout = 60000)
  public void testExpireAllPendingPwds() throws Exception {
    Session session = null;
    Transaction txn = null;
    TempPwd retInstance = null;
    TempPwd randomInstance = null;

    /* insert user */
    final User randomUser = TestUser.insertRandomUser();
    final String uid = randomUser.getUid();

    for (int i = 1; i <= 5; i++) {
      randomInstance = TestTempPwd.newRandomInstance();
      randomInstance.setUid(uid);

      /* insert */
      session = HibernateTestUtil.getSessionFactory().getCurrentSession();
      txn = session.beginTransaction();
      session.save(randomInstance);
      txn.commit();

      /* query */
      session = HibernateTestUtil.getSessionFactory().getCurrentSession();
      txn = session.beginTransaction();
      retInstance = (TempPwd) session.get(TempPwd.class,
          randomInstance.getId());
      txn.commit();

      /* verify */
      assertEquals(randomInstance, retInstance);
    }

    /* expire all pending ones */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();

    final int result = TempPwdUtil.expireAllPendingPwds(session, uid, true);
    assertEquals(5, result);
  }
}
