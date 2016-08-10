package com.gibbon.peeq.db.util;

import static org.junit.Assert.*;

import java.util.UUID;

import org.hibernate.Session;
import org.junit.Test;

import com.gibbon.peeq.db.model.TestUser;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.exceptions.SnoopException;

public class TestProfileUtil {
  @Test(timeout = 60000)
  public void testGetRateWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    Double result = null;
    try {
      result = ProfileUtil.getRate(session, UUID.randomUUID().toString(), true);
      fail("There shouldn't be any record.");
    } catch (Exception e) {
      assertTrue(e instanceof SnoopException);
    }
  }

  @Test(timeout = 60000)
  public void testGetRate() {
    final User user = TestUser.insertRandomUser();

    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    Double result = null;
    try {
      result = ProfileUtil.getRate(session, user.getUid(), true);
      assertEquals(result, user.getProfile().getRate());
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }
}
