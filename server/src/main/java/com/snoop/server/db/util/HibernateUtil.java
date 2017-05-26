package com.snoop.server.db.util;

import org.hibernate.SessionFactory;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.mortbay.log.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.snoop.server.web.HttpSnoopServer;

public class HibernateUtil {

  protected static final Logger LOG = LoggerFactory
      .getLogger(HibernateUtil.class);

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

  private static void setHibernateSQLDisplay(
      final Configuration configuration) {

    final String trueStr = Boolean.TRUE.toString();
    final String falseStr = Boolean.FALSE.toString();

    if (HttpSnoopServer.LIVE) {
      configuration.setProperty("hibernate.show_sql", falseStr);
      configuration.setProperty("hibernate.format_sql", falseStr);
      configuration.setProperty("hibernate.use_sql_comments", falseStr);
    } else {
      configuration.setProperty("hibernate.show_sql", trueStr);
      configuration.setProperty("hibernate.format_sql", trueStr);
      configuration.setProperty("hibernate.use_sql_comments", trueStr);
    }

    LOG.info("hibernate.show_sql ? {}",
        HttpSnoopServer.LIVE ? falseStr : trueStr);
    LOG.info("hibernate.format_sql? {}",
        HttpSnoopServer.LIVE ? falseStr : trueStr);
    LOG.info("hibernate.use_sql_comments ? {}",
        HttpSnoopServer.LIVE ? falseStr : trueStr);
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
    LOG.info("connection url set to {}", connectionUrlValue);
  }

  static SessionFactory buildSessionFactory(final String resource) {
    try {
      // Create the SessionFactory from hibernate-mysql.conf.xml
      Configuration configuration = new Configuration();
      LOG.info("resource is " + resource);
      configuration.configure(resource);
      LOG.info("Hibernate Configuration loaded");

      /* set parameters for live/test */
      setConnectionUrl(configuration);
      setHibernateSQLDisplay(configuration);

      ServiceRegistry serviceRegistry = new StandardServiceRegistryBuilder()
          .applySettings(configuration.getProperties()).build();
      LOG.info("Hibernate serviceRegistry created");

      SessionFactory sessionFactory = configuration
          .buildSessionFactory(serviceRegistry);

      return sessionFactory;
    } catch (Throwable ex) {
      // Make sure you log the exception, as it might be swallowed
      LOG.info("Initial SessionFactory creation failed." + ex);
      throw new ExceptionInInitializerError(ex);
    }
  }

  public static SessionFactory getSessionFactory() {
    return sessionFactory;
  }
}
