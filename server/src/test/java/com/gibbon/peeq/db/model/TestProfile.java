package com.gibbon.peeq.db.model;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class TestProfile {
  private static final Logger LOG = LoggerFactory.getLogger(TestProfile.class);

  @Test(timeout = 60000)
  public void testCreateProfileFromJson() throws IOException {
    final String json = "{\"uid\":\"edmund\",\"avatarImage\":\"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==\",\"fullName\":\"Edmund Burke\",\"title\":\"Philosopher\",\"aboutMe\":\"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.\"}";

    ObjectMapper mapper = new ObjectMapper();

    // convert json to object
    Profile profile = mapper.readValue(json, Profile.class);
    verifyProfileJason(profile);
  }

  private void verifyProfileJason(final Profile originalProfile)
      throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    // convert object to json
    String originalProfileJason = mapper.writeValueAsString(originalProfile);

    // convert json to object
    Profile newProfile = mapper.readValue(originalProfileJason, Profile.class);
    String newProfileJson = mapper.writeValueAsString(newProfile);
    assertEquals(originalProfileJason, newProfileJson);
    assertProfileEquals(originalProfile, newProfile);
  }

  private void assertProfileEquals(final Profile profile,
      final Profile anotherProfile) throws JsonProcessingException {
    assertEquals(profile.getUid(), anotherProfile.getUid());
    assertEquals(profile.toJsonStr(), anotherProfile.toJsonStr());
    profile.equals(anotherProfile);
  }
}
