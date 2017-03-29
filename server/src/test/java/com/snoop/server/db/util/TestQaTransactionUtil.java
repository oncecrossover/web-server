package com.snoop.server.db.util;

import static org.junit.Assert.*;

import org.hibernate.Session;
import org.junit.Test;

import com.snoop.server.db.model.QaTransaction;
import com.snoop.server.db.model.TestQaTransaction;
import com.snoop.server.db.util.HibernateTestUtil;
import com.snoop.server.db.util.QaTransactionUtil;
import com.snoop.server.exceptions.SnoopException;

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
