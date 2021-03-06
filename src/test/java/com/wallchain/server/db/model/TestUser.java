package com.wallchain.server.db.model;

import java.io.IOException;
import java.util.Random;
import java.util.UUID;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wallchain.server.db.model.PcAccount;
import com.wallchain.server.db.model.Profile;
import com.wallchain.server.db.model.User;
import com.wallchain.server.db.model.Profile.TakeQuestionStatus;
import com.wallchain.server.db.util.HibernateTestUtil;

import static org.junit.Assert.assertEquals;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestUser {
  private static final Logger LOG = LoggerFactory.getLogger(TestUser.class);
  private static Random random = new Random(System.currentTimeMillis());

  static User newRandomUser() {
    final User user = new User();
    user.setUname(UUID.randomUUID().toString())
        .setPwd(UUID.randomUUID().toString());

    final Profile profile = new Profile();
    profile.setRate(random.nextInt())
           .setAvatarUrl(UUID.randomUUID().toString())
           .setFullName(UUID.randomUUID().toString())
           .setTitle(UUID.randomUUID().toString())
           .setAboutMe(UUID.randomUUID().toString())
           .setTakeQuestion(TakeQuestionStatus.APPLIED.value())
           .setUser(user);

    final PcAccount pcAccount = new PcAccount();
    pcAccount.setChargeFrom(UUID.randomUUID().toString())
             .setPayTo(UUID.randomUUID().toString())
             .setUser(user);

    user.setProfile(profile);
    user.setPcAccount(pcAccount);

    return user;
  }

  static User newUser() {
    final User user = new User();
    user.setPwd("123");

    final Profile profile = new Profile();
    profile.setRate(101)
           .setAvatarUrl("https://en.wikiquote.org/wiki/Edmund_Burke")
           .setFullName("Edmund Burke")
           .setTitle("Philosopher")
           .setAboutMe(
            "I was an Irish political philosopher, Whig politician and statesman who"
                + " is often regarded as the father of modern conservatism.")
           .setTakeQuestion(TakeQuestionStatus.APPLIED.value())
           .setUser(user);

    final PcAccount pcAccount = new PcAccount();
    pcAccount.setChargeFrom("1234 5678")
             .setPayTo("5678 1234")
             .setUser(user);

    user.setProfile(profile);
    user.setPcAccount(pcAccount);

    return user;
  }

  static User newAnotherUser() {
    final User user = new User();
    user.setPwd("456");

    final Profile profile = new Profile();
    profile.setRate(1001)
           .setAvatarUrl("https://en.wikipedia.org/wiki/Guan_Zhong")
           .setFullName("Kuan Chung")
           .setTitle("Chancellor and Reformer")
           .setAboutMe(
            "I was was a chancellor and reformer of the State of Qi during the"
                + " Spring and Autumn Period of Chinese history.")
           .setTakeQuestion(TakeQuestionStatus.APPLIED.value())
           .setUser(user);

    final PcAccount pcAccount = new PcAccount();
    pcAccount.setChargeFrom("this_is_my_charge_from_account")
             .setPayTo("this_is_my_pay_to_account")
             .setUser(user);

    user.setProfile(profile);
    user.setPcAccount(pcAccount);

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

  public static User insertRandomUser() {
    final User user = newRandomUser();
    final Session session = HibernateTestUtil.getSessionFactory()
        .getCurrentSession();
    Transaction txn = session.beginTransaction();
    session.save(user);
    txn.commit();
    return user;
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

  public void testCreateUserFromJson() throws IOException {
    final String userJson = "{\"id\":\"edmund\",\"firstName\":\"Edmund\",\"middleName\":\"Peng\",\"lastName\":\"Burke\",\"pwd\":\"123\",\"profile\":{\"id\":null,\"avatarUrl\":\"https://en.wikiquote.org/wiki/Edmund_Burke\",\"avatarImage\":null,\"fullName\":\"Edmund Peng Burke\",\"title\":\"Philosopher\",\"aboutMe\":\"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.\"}}";
    ObjectMapper mapper = new ObjectMapper();

    // convert json to object
    User user = mapper.readValue(userJson, User.class);
    user.getProfile().setUser(user);
    user.getPcAccount().setUser(user);

    createAndVerifyUser(user);
  }

  private void createAndVerifyUser(final User user)
      throws JsonProcessingException {
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
    final User retUser = (User) session.get(User.class, user.getId());
    txn.commit();

    assertUserEquals(user, retUser);
  }

  private void assertUserEquals(final User user, final User anotherUser)
      throws JsonProcessingException {
    assertEquals(user.getId(), anotherUser.getId());
    assertEquals(user.toJsonStr(), anotherUser.toJsonStr());
    assertEquals(user, anotherUser);
  }

  /* test update user using HSQL embedded DB */
  //@Test(timeout = 60000)
  @Test
  public void testUpdateUser() throws JsonProcessingException {
    final User randomUser = newRandomUser();
    final User newRandomUser = newRandomUser()
                                .setProfile(randomUser.getProfile())
                                .setPcAccount(randomUser.getPcAccount());
    Session session = null;
    Transaction txn = null;
    User retUser = null;

    /* insert user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.save(randomUser);
    txn.commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retUser = (User) session.get(User.class, randomUser.getId());
    txn.commit();

    /* verify */
    assertUserEquals(randomUser, retUser);

    /* update user */
    newRandomUser.setId(randomUser.getId());
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    session.update(newRandomUser);
    txn.commit();

    /* query user */
    session = HibernateTestUtil.getSessionFactory().getCurrentSession();
    txn = session.beginTransaction();
    retUser = (User) session.get(User.class, randomUser.getId());
    txn.commit();

    /* verify */
    assertUserEquals(newRandomUser, retUser);
  }
}