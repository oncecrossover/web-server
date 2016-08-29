package com.gibbon.peeq.db.util;

import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.DoubleType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;
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

  public static List<Quanda> getExpiredQuandas()  throws Exception {
    final Session session = HibernateUtil.getSessionFactory()
        .getCurrentSession();
    return getExpiredQuandas(session, true);
  }

  public static List<Quanda> getExpiredQuandas(
      final Session session)  throws Exception {
    return getExpiredQuandas(session, false);
  }

  public static List<Quanda> getExpiredQuandas(
      final Session session,
      final boolean newTransaction)  throws Exception {
    final String sql = "SELECT id, asker, responder, rate, status,"
        + " createdTime FROM Quanda WHERE status = 'PENDING' AND"
        + " TIMESTAMPADD(SQL_TSI_HOUR, 48, createdTime) < CURRENT_TIMESTAMP;";
    Transaction txn = null;
    List<Quanda> list = null;
    try {
      if (newTransaction) {
        txn = session.beginTransaction();
      }

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Quanda.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("asker", new StringType())
           .addScalar("responder", new StringType())
           .addScalar("rate", new DoubleType())
           .addScalar("status", new StringType())
           .addScalar("createdTime", new TimestampType());
      list = query.list();

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
    return list;
  }
}
