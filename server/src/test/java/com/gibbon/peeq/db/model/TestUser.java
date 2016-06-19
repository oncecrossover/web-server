package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.db.util.HibernateTestUtil;

import static org.junit.Assert.assertEquals;

import org.hibernate.Session;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestUser {
  private static final Logger LOG = LoggerFactory.getLogger(TestUser.class);

  @Before
  public void setup() {
  }

  @After
  public void tearDown() {
  }

  @Test(timeout=60000)
  public void testUserToJason() throws IOException {
    ObjectMapper mapper = new ObjectMapper();
    User dummyUser = createDummyUser();

    // convert object to json
    String dummyUserJson = mapper.writeValueAsString(dummyUser);
    LOG.info(dummyUserJson);

    // convert json to object
    User user = mapper.readValue(dummyUserJson, User.class);
    String userJson = mapper.writeValueAsString(user);
    LOG.info(userJson);
    assertEquals(dummyUserJson, userJson);
  }

  private User createDummyUser() {
    User user = new User();
    user.setUid("xiaobingo")
        .setFirstName("Xiaobing")
        .setMiddleName("Xuan")
        .setLastName("Zhou")
        .setPwd("123")
        .setCreatedTime(new Date())
        .setUpdatedTime(new Date());

    return user;
  }

  /* test create user using HSQL embedded DB */
  @Test(timeout = 60000)
  public void testCreateUser() throws JsonProcessingException {
    final User dummyUser = createDummyUser();
    Session session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    session.save(dummyUser);
    session.getTransaction().commit();

    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    final User user = (User) session.get(User.class, dummyUser.getUid());
    session.getTransaction().commit();
    assertEquals(dummyUser.getUid(), user.getUid());
    assertEquals(dummyUser.toJson(), user.toJson());
  }
}