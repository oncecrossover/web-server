package com.gibbon.peeq.db.util;

import static org.junit.Assert.*;

import org.hibernate.Session;
import org.junit.Test;

import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.TestQaTransaction;
import com.gibbon.peeq.exceptions.SnoopException;

public class TestQaTransactionUtil {

  @Test(timeout = 60000)
  public void testGetQaTransactionWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final QaTransaction instance = TestQaTransaction.newRandomInstance();
    try {
      QaTransactionUtil.getQaTransaction(
          session,
          instance.getUid(),
          instance.getType(),
          instance.getQuandaId(),
          true);
    } catch (Exception e) {
      assertTrue(e instanceof SnoopException);
      assertTrue(e.getMessage().contains("Nonexistent qaTransaction"));
    }
  }

  @Test(timeout = 60000)
  public void testGetQaTransaction() throws Exception {
    /* insert QaTransaction */
    final QaTransaction instance = TestQaTransaction
        .insertRandomQaTransanction();

    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final QaTransaction resut =
        QaTransactionUtil.getQaTransaction(
          session,
          instance.getUid(),
          instance.getType(),
          instance.getQuandaId(),
          true);
    assertEquals(resut, instance);
  }
}
