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
  private PcAccount pcAccount;

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

  public PcAccount getPcAccount() {
    return pcAccount;
  }

  public User setPcAccount(final PcAccount pcAccount) {
    this.pcAccount = pcAccount;
    return this;
  }

  /**
   * Instantiates a new User.
   * @param userJson Json byte array of User.
   * @return new instance of User.
   */
  public static User newUser(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    final User user = mapper.readValue(json, User.class);

    if (user.getProfile() == null) {
      user.setProfile(new Profile());
    }
    user.getProfile().setUser(user);

    if (user.getPcAccount() == null) {
      user.setPcAccount(new PcAccount());
    }
    user.getPcAccount().setUser(user);
    return user;
  }

  @Override
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  public String toJsonStr() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }

  public byte[] toJsonByteArray() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsBytes(this);
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
      final User that = (User) obj;
      if (isEqual(this.getUid(), that.getUid())
          && isEqual(this.getFirstName(), that.getFirstName())
          && isEqual(this.getMiddleName(), that.getMiddleName())
          && isEqual(this.getLastName(), that.getLastName())
          && isEqual(this.getPwd(), that.getPwd())
          && isEqual(this.getProfile(), that.getProfile())
          && isEqual(this.getPcAccount(), that.getPcAccount())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }
}