package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;
import java.util.UUID;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.db.util.HibernateTestUtil;

import static org.junit.Assert.assertEquals;

import org.hibernate.Session;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestUser {
  private static final Logger LOG = LoggerFactory.getLogger(TestUser.class);

  private User newRandomUser() {
    User user = new User();
    user.setUid(UUID.randomUUID().toString())
        .setFirstName(UUID.randomUUID().toString())
        .setMiddleName(UUID.randomUUID().toString())
        .setLastName(UUID.randomUUID().toString())
        .setPwd(UUID.randomUUID().toString())
        .setCreatedTime(new Date())
        .setUpdatedTime(new Date());
    return user;
  }

  @Test(timeout=60000)
  public void testUserToJason() throws IOException {
    ObjectMapper mapper = new ObjectMapper();
    User randomUser = newRandomUser();

    // convert object to json
    String dummyUserJson = mapper.writeValueAsString(randomUser);
    LOG.info(dummyUserJson);

    // convert json to object
    User user = mapper.readValue(dummyUserJson, User.class);
    String userJson = mapper.writeValueAsString(user);
    LOG.info(userJson);
    assertEquals(dummyUserJson, userJson);
  }

  /* test create user using HSQL embedded DB */
  @Test(timeout = 60000)
  public void testCreateUser() throws JsonProcessingException {
    final User randomUser = newRandomUser();
    Session session = null;

    /* insert user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    session.save(randomUser);
    session.getTransaction().commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    final User user = (User) session.get(User.class, randomUser.getUid());
    session.getTransaction().commit();

    /* assert user */
    assertUserEqual(randomUser, user);
  }

  private void assertUserEqual(final User randomUser, final User user)
      throws JsonProcessingException {
    assertEquals(randomUser.getUid(), user.getUid());
    assertEquals(randomUser.toJson(), user.toJson());
  }

  /* test delete user using HSQL embedded DB */
  @Test(timeout = 60000)
  public void testDeleteUser() throws JsonProcessingException {
    final User randomUser = newRandomUser();
    Session session = null;

    /* insert user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    session.save(randomUser);
    session.getTransaction().commit();

    /* delete user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    session.delete(randomUser);
    session.getTransaction().commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    final User user = (User) session.get(User.class, randomUser.getUid());
    session.getTransaction().commit();

    /* assert user */
    assertEquals(null, user);
  }

  /* test update user using HSQL embedded DB */
  @Test(timeout = 60000)
  public void testUpdateUser() throws JsonProcessingException {
    final User randomUser = newRandomUser();
    final User newRandomUser = newRandomUser().setUid(randomUser.getUid());
    Session session = null;

    /* insert user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    session.save(randomUser);
    session.getTransaction().commit();

    /* update user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    session.update(newRandomUser);
    session.getTransaction().commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    session.beginTransaction();
    final User user = (User) session.get(User.class, randomUser.getUid());
    session.getTransaction().commit();

    /* assert user */
    assertUserEqual(newRandomUser, user);
  }
}