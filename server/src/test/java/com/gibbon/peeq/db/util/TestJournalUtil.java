package com.gibbon.peeq.db.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.UUID;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;

import com.gibbon.peeq.db.model.Journal;
import com.gibbon.peeq.db.model.Journal.JournalType;
import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.TestJournal;
import com.gibbon.peeq.db.model.TestQaTransaction;
import com.gibbon.peeq.db.model.TestUser;
import com.gibbon.peeq.db.model.User;

public class TestJournalUtil {

  @Test(timeout = 60000)
  public void testGetBalanceWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final Double result = JournalUtil.getBalance(session,
        UUID.randomUUID().toString(), true);
    assertEquals(null, result);
  }

  @Test(timeout = 60000)
  public void testGetBalance() throws Exception {
    Session session = null;
    Transaction txn = null;
    Journal retInstance = null;

    /* insert QaTransaction */
    final QaTransaction qaTransaction = TestQaTransaction
        .insertRandomQaTransanction();

    /* insert user */
    final User randomUser = TestUser.insertRandomUser();
    final String uid = randomUser.getUid();

    for (int i = 1; i <= 5; i++) {
      final Journal randomInstance = TestJournal.newRandomInstance();
      randomInstance.setTransactionId(qaTransaction.getId()).setUid(uid)
                    .setAmount(i * 12.3)
                    .setType(JournalType.BALANCE.toString());

      /* insert */
      session = HibernateTestUtil.getSessionFactory().getCurrentSession();
      txn = session.beginTransaction();
      session.save(randomInstance);
      txn.commit();

      /* query */
      session = HibernateTestUtil.getSessionFactory().getCurrentSession();
      txn = session.beginTransaction();
      retInstance = (Journal) session.get(Journal.class,
          randomInstance.getId());
      txn.commit();

      /* verify */
      assertEquals(randomInstance, retInstance);
    }

    /* handle balance */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();

    final Double result = JournalUtil.getBalance(session, uid, true);
    assertTrue(result != null);
    assertEquals(184.5, result.doubleValue(), 0);
  }
}
