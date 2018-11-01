package com.wallchain.server.db.model;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;

import com.wallchain.server.db.model.User;
import com.wallchain.server.db.util.HibernateWixUtil;
import com.wallchain.server.db.util.HibernateWixUtil.EmbeddedDBConnector;

import static org.junit.Assert.assertNull;

public class TestEmbeddedDBConnector extends EmbeddedDBConnector {
  @Test
  public void testQueryNonExistentUser() {
    final Session session = HibernateWixUtil.getSessionFactory()
        .getCurrentSession();
    final Transaction txn = session.beginTransaction();
    final User retInstance = (User) session.get(User.class, 123L);
    txn.commit();
    assertNull(retInstance);
  }
}