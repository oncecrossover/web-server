package com.wallchain.server.db.util;

import static org.junit.Assert.*;

import java.util.Random;

import org.hibernate.Session;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.wallchain.server.db.model.Profile;
import com.wallchain.server.db.model.TestUser;
import com.wallchain.server.db.model.User;
import com.wallchain.server.db.util.HibernateTestUtil;
import com.wallchain.server.db.util.ProfileDBUtil;
import com.wallchain.server.exceptions.SnoopException;

public class TestProfileDBUtil {

  protected static final Logger LOG = LoggerFactory
      .getLogger(TestProfileDBUtil.class);
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
      LOG.warn("expected SnoopException here.", e);
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
      result = ProfileDBUtil.getRate(session, user.getId(), true);
      assertEquals(user.getProfile().getRate(), result);
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }

  @Test(timeout = 60000)
  public void testGetProfileForNotification() {
    final User user = TestUser.insertRandomUser();

    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    Profile result = null;
    try {
      result = ProfileDBUtil.getProfileForNotification(session, user.getId(),
          true);
      assertNotNull(result);
      assertEquals(user.getProfile().getFullName(), result.getFullName());
      assertEquals(user.getProfile().getDeviceToken(), result.getDeviceToken());
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }
}
