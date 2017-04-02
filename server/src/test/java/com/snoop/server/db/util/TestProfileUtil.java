package com.snoop.server.db.util;

import static org.junit.Assert.*;

import java.util.Random;

import org.hibernate.Session;
import org.junit.Test;

import com.snoop.server.db.model.TestUser;
import com.snoop.server.db.model.User;
import com.snoop.server.db.util.HibernateTestUtil;
import com.snoop.server.db.util.ProfileDBUtil;
import com.snoop.server.exceptions.SnoopException;

public class TestProfileUtil {

  private Random r = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testGetRateWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    Integer result = null;
    try {
      result = ProfileDBUtil.getRate(session, r.nextLong(), true);
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

    Integer result = null;
    try {
      result = ProfileDBUtil.getRate(session, user.getUid(), true);
      assertEquals(result, user.getProfile().getRate());
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }
}
