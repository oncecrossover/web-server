package com.gibbon.peeq.db.util;

import org.hibernate.SessionFactory;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;

public class HibernateTestUtil {

  // XML based configuration
  private static SessionFactory sessionFactory;
  static {
    init();
  }

  private static void init() {
    if (sessionFactory == null) {
      sessionFactory = HibernateUtil.buildSessionFactory(
          "com/gibbon/peeq/scripts/hibernate-hsql.conf.xml");
    }
  }

  public static SessionFactory getSessionFactory() {
    return sessionFactory;
  }
}
