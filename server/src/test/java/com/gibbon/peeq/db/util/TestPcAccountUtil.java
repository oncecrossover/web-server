package com.gibbon.peeq.db.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.util.UUID;

import org.hibernate.Session;
import org.junit.Test;

import com.gibbon.peeq.db.model.TestUser;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.exceptions.SnoopException;

public class TestPcAccountUtil {
  @Test(timeout = 60000)
  public void testGetCustomerIdWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    String result = null;
    try {
      result = PcAccountUtil.getCustomerId(session,
          UUID.randomUUID().toString(), true);
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
      result = PcAccountUtil.getCustomerId(session, user.getUid(), true);
      assertEquals(result, user.getPcAccount().getChargeFrom());
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }
}
