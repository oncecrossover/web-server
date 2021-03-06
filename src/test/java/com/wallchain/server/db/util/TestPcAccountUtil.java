package com.wallchain.server.db.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.util.Random;
import java.util.UUID;

import org.hibernate.Session;
import org.junit.Test;

import com.wallchain.server.db.model.TestUser;
import com.wallchain.server.db.model.User;
import com.wallchain.server.db.util.HibernateTestUtil;
import com.wallchain.server.db.util.PcAccountUtil;
import com.wallchain.server.exceptions.SnoopException;

public class TestPcAccountUtil {
  private Random r = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testGetCustomerIdWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    String result = null;
    try {
      result = PcAccountUtil.getCustomerId(session, r.nextLong(), true);
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

    String result = null;
    try {
      result = PcAccountUtil.getCustomerId(session, user.getId(), true);
      assertEquals(result, user.getPcAccount().getChargeFrom());
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }
}
