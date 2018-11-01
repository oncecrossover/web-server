package com.wallchain.server.util;

import static org.junit.Assert.*;

import org.hibernate.Session;
import org.hibernate.SessionException;
import org.hibernate.Transaction;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import com.wallchain.server.db.util.HibernateTestUtil;

public class TestHibernateSession {

  @Rule
  public final ExpectedException exception = ExpectedException.none();

  /**
   * Tests Session is closed after the associated transaction is committed.
   */
  @Test(timeout = 60000)
  public void testCloseSession() {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    Transaction txn = null;
    try {
      txn = session.beginTransaction();
    } finally {
      txn.commit();
    }

    try {
      session.beginTransaction();
      fail("failed to throw SessionException");
    } catch (Exception e) {
      assertTrue("expected SessionException", e instanceof SessionException);
    }
  }
}
