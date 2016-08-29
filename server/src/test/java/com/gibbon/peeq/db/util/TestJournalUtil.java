package com.gibbon.peeq.db.util;

import static org.junit.Assert.*;

import java.util.UUID;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.Journal;
import com.gibbon.peeq.db.model.Journal.JournalType;
import com.gibbon.peeq.db.model.QaTransaction;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.model.TestJournal;
import com.gibbon.peeq.db.model.TestQaTransaction;
import com.gibbon.peeq.db.model.TestQuanda;
import com.gibbon.peeq.db.model.TestUser;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.exceptions.SnoopException;

public class TestJournalUtil {
  private static final Logger LOG = LoggerFactory
      .getLogger(TestJournalUtil.class);

  @Test(timeout = 60000)
  public void testGetPendingJournalWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final QaTransaction qaTransaction = TestQaTransaction.newRandomInstance();
    try {
      JournalUtil.getPendingJournal(session, qaTransaction, true);
    } catch (Exception e) {
      assertTrue(e instanceof SnoopException);
    }
  }

  @Test(timeout = 60000)
  public void testGetPendingJournal() throws Exception {
    Session session = null;
    Transaction txn = null;
    Journal retInstance = null;

    /* insert QaTransaction */
    final QaTransaction qaTransaction = TestQaTransaction
        .insertRandomQaTransanction();

    /* new pending journal */
    final Journal pendingJournal = newPendingJournal(qaTransaction);

    /* insert pending journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(pendingJournal);
    txn.commit();

    /* verify pending journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    retInstance = JournalUtil.getPendingJournal(session, qaTransaction, true);
    assertEquals(pendingJournal, retInstance);
  }

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

  @Test(timeout = 60000)
  public void testPendingJournalClearedWithoutRecords() throws Exception {
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();

    final Journal journal = TestJournal.newRandomInstance();

    final boolean result = JournalUtil.pendingJournalCleared(
        session,
        journal,
        true);
    assertFalse(result);
  }

  @Test(timeout = 60000)
  public void testPendingJournalCleared() throws Exception {
    Session session = null;
    Transaction txn = null;
    boolean result;

    /* insert QaTransaction */
    final QaTransaction qaTransaction = TestQaTransaction
        .insertRandomQaTransanction();

    /* new pending journal */
    final Journal pendingJournal = newPendingJournal(qaTransaction);

    /* insert pending journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(pendingJournal);
    txn.commit();

    /* verify pending cleared */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    result  = JournalUtil.pendingJournalCleared(session, pendingJournal, true);
    assertFalse(result);

    /* insert clearance journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    JournalUtil.insertClearanceJournal(session, pendingJournal, true);

    /* verify pending cleared */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    result  = JournalUtil.pendingJournalCleared(session, pendingJournal, true);
    assertTrue(result);
  }

  @Test(timeout = 60000)
  public void testInsertClearanceJournal() throws Exception {
    Session session = null;
    Transaction txn = null;
    final Journal retInstance;

    /* insert QaTransaction */
    final QaTransaction qaTransaction = TestQaTransaction
        .insertRandomQaTransanction();

    /* new pending journal */
    final Journal pendingJournal = newPendingJournal(qaTransaction);

    /* insert pending journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(pendingJournal);
    txn.commit();

    /* insert clearance journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    final Journal clearanceJournal = JournalUtil.insertClearanceJournal(
        session,
        pendingJournal,
        true);

    /* verify clearance journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (Journal) session.get(
        Journal.class,
        clearanceJournal.getId());
    txn.commit();

    assertEquals(retInstance, clearanceJournal);
  }

  @Test(timeout = 60000)
  public void testInsertResponderJournal() throws Exception {
    Session session = null;
    Transaction txn = null;
    final Journal retInstance;

    /* insert QaTransaction */
    final QaTransaction qaTransaction = TestQaTransaction
        .insertRandomQaTransanction();

    /* new pending journal */
    final Journal pendingJournal = newPendingJournal(qaTransaction);

    /* insert pending journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(pendingJournal);
    txn.commit();

    /* insert clearance journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    final Journal clearanceJournal = JournalUtil.insertClearanceJournal(
        session,
        pendingJournal,
        true);

    /* insert responder journal */
    final Quanda quanda = TestQuanda.insertRandomQuanda();
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    final Journal responderJournal = JournalUtil.insertResponderJournal(
        session,
        clearanceJournal,
        quanda,
        true);

    /* verify responder journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (Journal) session.get(
        Journal.class,
        responderJournal.getId());
    txn.commit();

    assertEquals(retInstance, responderJournal);
  }

  @Test(timeout = 60000)
  public void testInsertRefundJournal() throws Exception {
    Session session = null;
    Transaction txn = null;
    final Journal retInstance;

    /* insert QaTransaction */
    final QaTransaction qaTransaction = TestQaTransaction
        .insertRandomQaTransanction();

    /* new pending journal */
    final Journal pendingJournal = newPendingJournal(qaTransaction);

    /* insert pending journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(pendingJournal);
    txn.commit();

    /* insert clearance journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    final Journal clearanceJournal = JournalUtil.insertClearanceJournal(
        session,
        pendingJournal,
        true);

    /* insert refund journal */
    final Quanda quanda = TestQuanda.insertRandomQuanda();
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    final Journal refundJournal = JournalUtil.insertRefundJournal(
        session,
        clearanceJournal,
        quanda,
        true);

    /* verify refund journal */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retInstance = (Journal) session.get(
        Journal.class,
        refundJournal.getId());
    txn.commit();

    assertEquals(retInstance, refundJournal);
  }

  private Journal newPendingJournal(final QaTransaction qaTransaction) {
    final Journal result = new Journal();
    result.setTransactionId(qaTransaction.getId())
           .setUid(qaTransaction.getUid())
           .setAmount(-1 * qaTransaction.getAmount())
           .setType(JournalType.BALANCE.toString())
           .setChargeId(null)
           .setStatus(Journal.Status.PENDING.value())
           .setOriginId(null);
    return result;
  }
}
