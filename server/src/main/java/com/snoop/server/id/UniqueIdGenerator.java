package com.snoop.server.id;

import java.io.Serializable;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SessionImplementor;
import org.hibernate.id.IdentifierGenerator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.snoop.server.conf.Configuration;
import com.snoop.server.exceptions.InvalidSystemClock;

public class UniqueIdGenerator implements IdentifierGenerator {
  protected static final Logger LOG = LoggerFactory
      .getLogger(UniqueIdGenerator.class);
  private final static IdWorker ID_WORKER;

  static {
    ID_WORKER = new IdWorker(getWorkerId(), getDatacenterId());
  }

  private static int getWorkerId() {
    return getInt(
        Configuration.SNOOP_SERVER_ID_WORKER_ID_KEY,
        Configuration.SNOOP_SERVER_ID_WORKER_ID_DEFAULT);
  }

  private static int getDatacenterId() {
    return getInt(
        Configuration.SNOOP_SERVER_ID_DATACENTER_ID_KEY,
        Configuration.SNOOP_SERVER_ID_DATACENTER_ID_DEFAULT);
  }

  private static int getInt(final String key, final int defaultInt) {
    final String value = System.getProperty(key);
    return value != null ? Integer.parseInt(value) : defaultInt;
  }

  @Override
  public Serializable generate(SessionImplementor session, Object object)
      throws HibernateException {
    while (true) {
      try {
        return ID_WORKER.nextId();
      } catch (InvalidSystemClock e) {
        LOG.warn("trying to wait for clock moving forward to catch up.", e);
      }
    }
  }
}
