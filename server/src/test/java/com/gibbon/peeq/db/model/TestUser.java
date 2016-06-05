package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;
import com.fasterxml.jackson.databind.ObjectMapper;
import static org.junit.Assert.assertEquals;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestUser {
  private static final Logger LOG = LoggerFactory.getLogger(TestUser.class);

  @Test
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
    user.setUid("xiaobingo");
    user.setFirstName("Xiaobing");
    user.setMiddleName("Yunxuan");
    user.setLastName("Zhou");
    user.setPwd("123");
    user.setInsertTime(new Date());
    return user;
  }
}
