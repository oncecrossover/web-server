package com.snoop.server.db.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Random;

import org.apache.commons.lang3.time.DateUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.snoop.server.db.model.Quanda;
import com.snoop.server.db.model.TestQuanda;
import com.snoop.server.db.util.HibernateTestUtil;
import com.snoop.server.db.util.QuandaDBUtil;
import com.snoop.server.exceptions.SnoopException;

public class TestQuandaDBUtil {
  private static Random random = new Random(System.currentTimeMillis());

  @Test(timeout = 60000)
  public void testGetQuandaWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();
    try {
      QuandaDBUtil.getQuanda(session, random.nextLong(), true);
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
      result = QuandaDBUtil.getQuanda(session, auanda.getId(), true);
      assertEquals(result, auanda);
    } catch (Exception e) {
      fail("There should be any record.");
    }
  }

  @Test(timeout = 60000)
  public void testGetExpiredQuandasWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    List<Quanda> list = QuandaDBUtil.getExpiredQuandas(session , true);
    assertEquals(0, list.size());
  }

  @Test(timeout = 60000)
  public void testGetExpiredQuandas() throws Exception {
    Session session = null;
    Transaction txn = null;
    List<Quanda> list = null;
    Quanda resInstance = null;

    Quanda quanda1 = null;
    Quanda quanda2 = null;
    Quanda quanda3 = null;
    Quanda quanda4 = null;

    quanda1 = TestQuanda.insertRandomQuanda();
    quanda2 = TestQuanda.insertRandomQuanda();
    quanda3 = TestQuanda.insertRandomQuanda();
    quanda4 = TestQuanda.insertRandomQuanda();

    /* no one expired */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    list = QuandaDBUtil.getExpiredQuandas(session, true);
    assertEquals(0, list.size());

    /**
     * expire one quanda
     */
    /* query createdTime of quanda1 */
    resInstance = quanda1;
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance = QuandaDBUtil.getQuanda(session, resInstance.getId(), true);

    /* change createdTime to 72 hours earlier */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance
        .setCreatedTime(DateUtils.addHours(resInstance.getCreatedTime(), -72));
    txn = session.beginTransaction();
    session.update(resInstance);
    txn.commit();

    /* verify one expired */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    list = QuandaDBUtil.getExpiredQuandas(session, true);
    assertEquals(1, list.size());
    assertEquals(resInstance.getId(), list.get(0).getId());

    /**
     * expire two quandas
     */
    /* query createdTime of quanda2 */
    resInstance = quanda2;
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance = QuandaDBUtil.getQuanda(session, resInstance.getId(), true);

    /* change createdTime to 72 hours earlier */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance
        .setCreatedTime(DateUtils.addHours(resInstance.getCreatedTime(), -72));
    txn = session.beginTransaction();
    session.update(resInstance);
    txn.commit();

    /* verify two expired */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    list = QuandaDBUtil.getExpiredQuandas(session, true);
    Collections.sort(list, QuandaComparator);
    assertEquals(2, list.size());
    assertEquals(quanda1.getId(), list.get(0).getId());
    assertEquals(resInstance.getId(), list.get(1).getId());

    /**
     * expire three quandas
     */
    /* query createdTime of quanda3 */
    resInstance = quanda3;
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance = QuandaDBUtil.getQuanda(session, resInstance.getId(), true);

    /* change createdTime to 72 hours earlier */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance
        .setCreatedTime(DateUtils.addHours(resInstance.getCreatedTime(), -72));
    txn = session.beginTransaction();
    session.update(resInstance);
    txn.commit();

    /* verify three expired */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    list = QuandaDBUtil.getExpiredQuandas(session, true);
    Collections.sort(list, QuandaComparator);
    assertEquals(3, list.size());
    assertEquals(quanda1.getId(), list.get(0).getId());
    assertEquals(quanda2.getId(), list.get(1).getId());
    assertEquals(resInstance.getId(), list.get(2).getId());

    /**
     * expire four quandas
     */
    /* query createdTime of quanda4 */
    resInstance = quanda4;
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance = QuandaDBUtil.getQuanda(session, resInstance.getId(), true);

    /* change createdTime to 72 hours earlier */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    resInstance
        .setCreatedTime(DateUtils.addHours(resInstance.getCreatedTime(), -72));
    txn = session.beginTransaction();
    session.update(resInstance);
    txn.commit();

    /* verify four expired */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    list = QuandaDBUtil.getExpiredQuandas(session, true);
    Collections.sort(list, QuandaComparator);
    assertEquals(4, list.size());
    assertEquals(quanda1.getId(), list.get(0).getId());
    assertEquals(quanda2.getId(), list.get(1).getId());
    assertEquals(quanda3.getId(), list.get(2).getId());
    assertEquals(resInstance.getId(), list.get(3).getId());
  }

  static Comparator<Quanda> QuandaComparator = new Comparator<Quanda>() {
    @Override
    public int compare(Quanda o1, Quanda o2) {
      /* ascending order */
      return o1.getId().compareTo(o2.getId());
    }
  };
}