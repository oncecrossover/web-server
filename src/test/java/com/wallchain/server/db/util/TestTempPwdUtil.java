package com.wallchain.server.db.util;

import static org.junit.Assert.assertEquals;

import java.util.Random;
import java.util.UUID;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;

import com.wallchain.server.db.model.TempPwd;
import com.wallchain.server.db.model.TestTempPwd;
import com.wallchain.server.db.model.TestUser;
import com.wallchain.server.db.model.User;
import com.wallchain.server.db.util.HibernateTestUtil;
import com.wallchain.server.db.util.TempPwdUtil;

public class TestTempPwdUtil {

  private Random r = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testTempPwdExists4UserWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final boolean result = TempPwdUtil.tempPwdExists4User(session,
        r.nextLong(), UUID.randomUUID().toString(), true);
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
    final Long uid = randomUser.getId();

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
        r.nextLong(), true);
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
    final Long uid = randomUser.getId();

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
