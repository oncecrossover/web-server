package com.wallchain.server.db.util;

import org.hibernate.SessionFactory;

public class HibernateTestUtil {

  // XML based configuration
  private static SessionFactory sessionFactory;
  static {
    init();
  }

  private static void init() {
    if (sessionFactory == null) {
      sessionFactory = HibernateUtil.buildSessionFactory(
          "com/wallchain/server/scripts/hibernate-hsql.conf.xml");
    }
  }

  public static SessionFactory getSessionFactory() {
    return sessionFactory;
  }
}
