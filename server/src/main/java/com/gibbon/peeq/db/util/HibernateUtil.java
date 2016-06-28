package com.gibbon.peeq.db.util;

import org.hibernate.SessionFactory;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;

public class HibernateUtil {

  // XML based configuration
  private static SessionFactory sessionFactory;

  static {
    init();
  }

  private static void init() {
    if (sessionFactory == null) {
      sessionFactory = buildSessionFactory(
          "com/gibbon/peeq/scripts/hibernate-mysql.conf.xml");
    }
  }

  static SessionFactory buildSessionFactory(final String resource) {
    try {
      // Create the SessionFactory from hibernate-mysql.conf.xml
      Configuration configuration = new Configuration();
      System.out.println("resource is " + resource);
      configuration.configure(resource);
      System.out.println("Hibernate Configuration loaded");

      ServiceRegistry serviceRegistry = new StandardServiceRegistryBuilder()
          .applySettings(configuration.getProperties()).build();
      System.out.println("Hibernate serviceRegistry created");

      SessionFactory sessionFactory = configuration
          .buildSessionFactory(serviceRegistry);

      return sessionFactory;
    } catch (Throwable ex) {
      // Make sure you log the exception, as it might be swallowed
      System.err.println("Initial SessionFactory creation failed." + ex);
      throw new ExceptionInInitializerError(ex);
    }
  }

  public static SessionFactory getSessionFactory() {
    return sessionFactory;
  }
}
