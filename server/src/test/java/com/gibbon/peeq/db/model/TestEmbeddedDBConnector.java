package com.gibbon.peeq.db.model;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;

import com.gibbon.peeq.db.util.HibernateWixUtil;
import com.gibbon.peeq.db.util.HibernateWixUtil.EmbeddedDBConnector;
import static org.junit.Assert.assertNull;

public class TestEmbeddedDBConnector extends EmbeddedDBConnector {
  @Test
  public void testQueryNonExistentUser() {
    final Session session = HibernateWixUtil.getSessionFactory()
        .getCurrentSession();
    final Transaction txn = session.beginTransaction();
    final User retInstance = (User) session.get(User.class, "bingo");
    txn.commit();
    assertNull(retInstance);
  }
}