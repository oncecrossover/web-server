package com.gibbon.peeq.db.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.util.Random;

import org.hibernate.Session;
import org.junit.Test;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.model.TestQuanda;
import com.gibbon.peeq.exceptions.SnoopException;

public class TestQuandaUtil {
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testGetQuandaWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    Quanda result = null;
    try {
      result = QuandaUtil.getQuanda(session, random.nextLong(), true);
      fail("There shouldn't be any record.");
    } catch (Exception e) {
      assertTrue(e instanceof SnoopException);
    }
  }

  @Test(timeout = 60000)
  public void testGetQuanda() throws JsonProcessingException {
    final Quanda auanda = TestQuanda.insertRandomQuanda();

    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    Quanda result = null;
    try {
      result = QuandaUtil.getQuanda(session, auanda.getId(), true);
      assertEquals(result, auanda);
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }
}