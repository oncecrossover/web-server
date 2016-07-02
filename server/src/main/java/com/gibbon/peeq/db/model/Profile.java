package com.gibbon.peeq.db.model;

import java.io.IOException;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Profile {
  private String uid;
  private String avatarUrl;
  private byte[] avatarImage;
  private String fullName;
  private String title;
  private String aboutMe;
  @JsonIgnore
  private User user;

  public String getUid() {
    return uid;
  }

  public Profile setUid(final String uid) {
    this.uid = uid;
    return this;
  }

  public String getAvatarUrl() {
    return avatarUrl;
  }

  public Profile setAvatarUrl(final String avatarUrl) {
    this.avatarUrl = avatarUrl;
    return this;
  }

  public byte[] getAvatarImage() {
    return avatarImage;
  }

  public Profile setAvatarImage(final byte[] avatarImage) {
    this.avatarImage = avatarImage;
    return this;
  }

  public String getFullName() {
    return fullName;
  }

  public Profile setFullName(final String fullName) {
    this.fullName = fullName;
    return this;
  }

  public String getTitle() {
    return title;
  }

  public Profile setTitle(final String title) {
    this.title = title;
    return this;
  }

  public String getAboutMe() {
    return aboutMe;
  }

  public Profile setAboutMe(final String aboutMe) {
    this.aboutMe = aboutMe;
    return this;
  }

  @JsonIgnore
  public User getUser() {
    return user;
  }

  @JsonIgnore
  public Profile setUser(final User user) {
    this.user = user;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj == null) {
      return false;
    }

    if (getClass() == obj.getClass()) {
      Profile profile = (Profile) obj;
      if (this.getUid() == profile.getUid()
          && this.getAvatarUrl() == profile.getAvatarUrl()
          && this.getAvatarImage() == profile.getAvatarImage()
          && this.getFullName() == profile.getFullName()
          && this.getTitle() == profile.getTitle()
          && this.getAboutMe() == profile.getAboutMe()) {
        return true;
      }
    }

    return false;
  }

  @Override
  public String toString() {
    try {
      return toJson();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  public String toJson() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }

  public static Profile newProfile(final String json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    Profile profile = mapper.readValue(json, Profile.class);
    return profile;
  }
}
