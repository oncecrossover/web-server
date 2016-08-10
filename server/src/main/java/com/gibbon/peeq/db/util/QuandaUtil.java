package com.gibbon.peeq.db.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.exceptions.SnoopException;

public class QuandaUtil {
  protected static final Logger LOG = LoggerFactory.getLogger(QuandaUtil.class);

  /*
   * query from a session that will open new transaction.
   */
  public static Quanda getQuanda(final long id) throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getQuanda(session, id, true);
  }

  /*
   * query from a session that already opened transaction.
   */
  public static Quanda getQuanda(final Session session, final long id)
      throws Exception {
    return getQuanda(session, id, false);
  }

  static Quanda getQuanda(final Session session, final long id,
      final boolean newTransaction) throws Exception {
    Transaction txn = null;
    Quanda retInstance = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }
      retInstance = (Quanda) session.get(Quanda.class, id);
      if (txn != null) {
        txn.commit();
      }
    } catch (HibernateException e) {
      if (txn != null) {
        txn.rollback();
      }
      throw e;
    } catch (Exception e) {
      throw e;
    }

    if (retInstance == null) {
      throw new SnoopException(String.format("Nonexistent quanda ('%d')", id));
    }

    return retInstance;
  }
}
