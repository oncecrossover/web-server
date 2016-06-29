package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class User {
  private String uid;
  private String firstName;
  private String middleName;
  private String lastName;
  private String pwd;
  private Date createdTime;
  private Date updatedTime;
  private Profile profile;

  public String getUid() {
    return uid;
  }

  public User setUid(String uid) {
    this.uid = uid;
    return this;
  }

  public String getFirstName() {
    return this.firstName;
  }

  public User setFirstName(String firstName) {
    this.firstName = firstName;
    return this;
  }

  public String getMiddleName() {
    return this.middleName;
  }

  public User setMiddleName(String middleName) {
    this.middleName = middleName;
    return this;
  }

  public String getLastName() {
    return this.lastName;
  }

  public User setLastName(String lastName) {
    this.lastName = lastName;
    return this;
  }

  public String getPwd() {
    return pwd;
  }

  public User setPwd(String pwd) {
    this.pwd = pwd;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public User setCreatedTime(Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public User setUpdatedTime(Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public Profile getProfile() {
    return profile;
  }

  public User setProfile(final Profile profile) {
    this.profile = profile;
    return this;
  }

  /**
   * Instantiates a new User.
   * @param userJson Json string of User.
   * @return new instance of User.
   */
  public static User newUser(final String userJson)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    User user = mapper.readValue(userJson, User.class);
    user.getProfile().setUser(user);
    return user;
  }

  @Override
  public String toString() {
    if (StringUtils.isBlank(middleName)) {
      return String.format("%s, %s %s, %s, %s,", uid, firstName,
          lastName, pwd, createdTime);
    } else {
      return String.format("%s, %s %s %s, %s, %s,", uid, firstName,
          middleName, lastName, pwd, createdTime);
    }
  }

  public String toJson() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
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
      User user = (User) obj;
      if (this.getUid() == user.getUid()
          && this.getFirstName() == user.getFirstName()
          && this.getMiddleName() == user.getMiddleName()
          && this.getLastName() == user.getLastName()
          && this.getPwd() == user.getPwd()
          && this.getCreatedTime() == user.getCreatedTime()
          && this.getUpdatedTime() == user.getUpdatedTime()
          && this.getProfile().equals(user.getProfile())) {
        return true;
      }
    }

    return false;
  }
}