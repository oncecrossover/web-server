package com.gibbon.peeq.db.util;

import static com.wix.mysql.EmbeddedMysql.anEmbeddedMysql;
import static com.wix.mysql.ScriptResolver.classPathScript;
import static com.wix.mysql.config.MysqldConfig.aMysqldConfig;
import static com.wix.mysql.distribution.Version.v5_6_latest;

import java.util.concurrent.TimeUnit;

import org.hibernate.SessionFactory;
import org.junit.After;
import org.junit.Before;

import com.wix.mysql.EmbeddedMysql;
import com.wix.mysql.config.Charset;
import com.wix.mysql.config.MysqldConfig;

public class HibernateWixUtil {
  // XML based configuration
  private static SessionFactory sessionFactory;
  static {
    init();
  }

  private static void init() {
    if (sessionFactory == null) {
      sessionFactory = HibernateUtil.buildSessionFactory(
          "com/gibbon/peeq/scripts/hibernate-wix.conf.xml");
    }
  }

  public static SessionFactory getSessionFactory() {
    return sessionFactory;
  }

  public static class EmbeddedDBConnector {
    EmbeddedMysql mysqld = null;
    @Before
    public void setup() {
      final MysqldConfig config = aMysqldConfig(v5_6_latest)
          .withCharset(Charset.UTF8)
          .withPort(2215)
          .withTimeout(2, TimeUnit.MINUTES)
          .build();

      mysqld = anEmbeddedMysql(config)
          .addSchema(
              "aschema",
              classPathScript("com/gibbon/peeq/scripts/schema.sql"))
          .start();
    }

    @After
    public void tearDown() {
      if (mysqld != null) {
        mysqld.stop();
      }
    }
  }
}
