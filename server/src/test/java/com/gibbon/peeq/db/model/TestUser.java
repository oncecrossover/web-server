package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;
import java.util.UUID;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.db.util.HibernateTestUtil;

import static org.junit.Assert.assertEquals;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestUser {
  private static final Logger LOG = LoggerFactory.getLogger(TestUser.class);

  static User newRandomUser() {
    User user = new User();
    user.setUid(UUID.randomUUID().toString())
        .setFirstName(UUID.randomUUID().toString())
        .setMiddleName(UUID.randomUUID().toString())
        .setLastName(UUID.randomUUID().toString())
        .setPwd(UUID.randomUUID().toString())
        .setCreatedTime(new Date())
        .setUpdatedTime(new Date());

    Profile profile = new Profile();
    profile.setAvatarUrl(UUID.randomUUID().toString())
           .setFullName(String.format("%s %s %s", user.getFirstName(),
               user.getMiddleName(), user.getLastName()))
           .setTitle(UUID.randomUUID().toString())
           .setAboutMe(UUID.randomUUID().toString())
           .setUser(user);

    user.setProfile(profile);

    return user;
  }

  static User newUser() {
    User user = new User();
    user.setUid("edmund")
        .setFirstName("Edmund")
        .setMiddleName("Peng")
        .setLastName("Burke")
        .setPwd("123")
        .setCreatedTime(new Date())
        .setUpdatedTime(new Date());

    Profile profile = new Profile();
    profile.setAvatarUrl("https://en.wikiquote.org/wiki/Edmund_Burke")
           .setFullName(String.format("%s %s %s", user.getFirstName(),
               user.getMiddleName(), user.getLastName()))
           .setTitle("Philosopher")
           .setAboutMe(
            "I was an Irish political philosopher, Whig politician and statesman who"
                + " is often regarded as the father of modern conservatism.")
           .setUser(user);

    user.setProfile(profile);

    return user;
  }

  static User newAnotherUser() {
    User user = new User();
    user.setUid("kuan")
        .setFirstName("Kuan")
        .setMiddleName("Shuya")
        .setLastName("Chung")
        .setPwd("456")
        .setCreatedTime(new Date())
        .setUpdatedTime(new Date());

    Profile profile = new Profile();
    profile.setAvatarUrl("https://en.wikipedia.org/wiki/Guan_Zhong")
           .setFullName(String.format("%s %s %s", user.getFirstName(),
               user.getMiddleName(), user.getLastName()))
           .setTitle("Chancellor and Reformer")
           .setAboutMe(
            "I was was a chancellor and reformer of the State of Qi during the"
                + " Spring and Autumn Period of Chinese history.")
           .setUser(user);

    user.setProfile(profile);

    return user;
  }

  private void verifyUserJason(final User originalUser) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalUserJason = mapper.writeValueAsString(originalUser);

    // convert json to object
    User newUser = mapper.readValue(originalUserJason, User.class);
    String newUserJson = mapper.writeValueAsString(newUser);
    assertEquals(originalUserJason, newUserJson);
    assertUserEquals(originalUser, newUser);
  }

  @Test(timeout = 60000)
  public void testUserToJason() throws IOException {
    verifyUserJason(newUser());
  }

  @Test(timeout = 60000)
  public void testAnotherUserToJason() throws IOException {
    verifyUserJason(newAnotherUser());
  }

  @Test(timeout = 60000)
  public void testRandomUserToJason() throws IOException {
    verifyUserJason(newRandomUser());
  }

  /* test create user using HSQL embedded DB */
  @Test(timeout = 60000)
  public void testCreateUser() throws JsonProcessingException {
    createAndVerifyUser(newRandomUser());
  }

  @Test(timeout = 60000)
  public void testCreateUserFromJson() throws IOException {
    final String userJson = "{\"uid\":\"edmund\",\"firstName\":\"Edmund\",\"middleName\":\"Peng\",\"lastName\":\"Burke\",\"pwd\":\"123\",\"createdTime\":1467156716625,\"updatedTime\":1467156716625,\"profile\":{\"uid\":null,\"avatarUrl\":\"https://en.wikiquote.org/wiki/Edmund_Burke\",\"avatarImage\":null,\"fullName\":\"Edmund Peng Burke\",\"title\":\"Philosopher\",\"aboutMe\":\"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.\"}}";

    ObjectMapper mapper = new ObjectMapper();

    // convert json to object
    User user = mapper.readValue(userJson, User.class);
    user.getProfile().setUser(user);

    createAndVerifyUser(user);
  }

  private void createAndVerifyUser(final User user) {
    Session session = null;
    Transaction txn = null;

    /* insert user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(user);
    txn.commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    final User retUser = (User) session.get(User.class, user.getUid());
    txn.commit();

    assertEquals(user.getUid(), retUser.getUid());
  }

  private void assertUserEquals(final User user, final User anotherUser)
      throws JsonProcessingException {
    assertEquals(user.getUid(), anotherUser.getUid());
    assertEquals(user.toJsonStr(), anotherUser.toJsonStr());
    user.equals(anotherUser);
  }

  /* test delete user using HSQL embedded DB */
  @Test(timeout = 60000)
  public void testDeleteUser() throws JsonProcessingException {
    final User randomUser = newRandomUser();
    Session session = null;
    Transaction txn = null;

    /* insert user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(randomUser);
    txn.commit();

    /* delete user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.delete(randomUser);
    txn.commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    final User user = (User) session.get(User.class, randomUser.getUid());
    txn.commit();

    /* assert user */
    assertEquals(null, user);
  }

  /* test update user using HSQL embedded DB */
  @Test(timeout = 60000)
  public void testUpdateUser() throws JsonProcessingException {
    final User randomUser = newRandomUser();
    final User newRandomUser = newRandomUser()
                                .setUid(randomUser.getUid())
                                .setProfile(randomUser.getProfile());

    Session session = null;
    Transaction txn = null;

    /* insert user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(randomUser);
    txn.commit();

    /* update user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.update(newRandomUser);
    txn.commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    final User user = (User) session.get(User.class, randomUser.getUid());
    txn.commit();

    /* assert user */
    assertEquals(randomUser.getUid(), user.getUid());
  }
}