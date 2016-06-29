package com.gibbon.peeq.db.model;

import java.io.IOException;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.databind.ObjectMapper;

public class TestProfile {
  private static final Logger LOG = LoggerFactory.getLogger(TestProfile.class);

  @Test(timeout = 60000)
  public void testCreateProfileFromJson() throws IOException {
    final String json = "{\"uid\":\"edmund\",\"avatarUrl\":\"https://en.wikiquote.org/wiki/Edmund_Burke\",\"avatarImage\":null,\"fullName\":\"Edmund Burke\",\"title\":\"Philosopher\",\"aboutMe\":\"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.\"}";
    LOG.info(json);

    ObjectMapper mapper = new ObjectMapper();

    // convert json to object
    Profile profile = mapper.readValue(json, Profile.class);
  }
}
