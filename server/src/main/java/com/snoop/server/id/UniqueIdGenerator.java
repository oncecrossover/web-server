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
    ID_WORKER = new IdWorker(
        Configuration.COM_SNOOP_SERVER_ID_WORKER_ID_DEFAULT,
        Configuration.COM_SNOOP_SERVER_ID_DATACENTER_ID_DEFAULT);
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
