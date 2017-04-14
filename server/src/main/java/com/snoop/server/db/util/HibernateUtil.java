package com.snoop.server.db.util;

import org.hibernate.SessionFactory;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;

import com.snoop.server.web.HttpSnoopServer;

public class HibernateUtil {

  // XML based configuration
  private static SessionFactory sessionFactory;

  private HibernateUtil() {
  }

  static {
    init();
  }

  private static void init() {
    if (sessionFactory == null) {
      sessionFactory = buildSessionFactory(
          "com/snoop/server/scripts/hibernate-mysql.conf.xml");
    }
  }

  private static void setConnectionUrl(final Configuration configuration) {
    final String connectionUrlKey = "hibernate.connection.url";

    /* use settings in conf file */
    if (configuration.getProperty(connectionUrlKey) != null) {
      return;
    }

    String connectionUrlValue;
    if (HttpSnoopServer.LIVE) {
      connectionUrlValue = "jdbc:mysql://localhost/snoopdb";
      configuration.setProperty(connectionUrlKey, connectionUrlValue);
    } else {
      connectionUrlValue = "jdbc:mysql://localhost/snooptestdb";
      configuration.setProperty(connectionUrlKey, connectionUrlValue);
    }
    System.out
        .println(String.format("connection url set to %s", connectionUrlValue));
  }

  static SessionFactory buildSessionFactory(final String resource) {
    try {
      // Create the SessionFactory from hibernate-mysql.conf.xml
      Configuration configuration = new Configuration();
      System.out.println("resource is " + resource);
      configuration.configure(resource);
      System.out.println("Hibernate Configuration loaded");

      setConnectionUrl(configuration);

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
