package com.snoop.server.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.snoop.server.db.model.Profile.TakeQuestionStatus;

public class User {
  private Long id;
  private String uname;
  private String pwd;
  private String primaryEmail;
  private Date createdTime;
  private Date updatedTime;
  private String fullName;
  private Profile profile;
  private PcAccount pcAccount;

  public Long getId() {
    return id;
  }

  public User setId(Long id) {
    this.id = id;
    return this;
  }

  public String getUname() {
    return uname;
  }

  public User setUname(final String uname) {
    this.uname = uname;
    return this;
  }

  public String getFullName() {
    return fullName;
  }

  public User setFullName(final String fullName) {
    this.fullName = fullName;
    return this;
  }

  public String getPwd() {
    return pwd;
  }

  public User setPwd(String pwd) {
    this.pwd = pwd;
    return this;
  }

  public String getPrimaryEmail() {
    return primaryEmail;
  }

  public User setPrimaryEmail(final String primaryEmail) {
    this.primaryEmail = primaryEmail;
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
  public static User newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    final User user = mapper.readValue(json, User.class);
    /* always make uname case insensitive */
    user.uname = user.uname != null ? user.uname.toLowerCase() : user.uname;

    if (user.getProfile() == null) {
      user.setProfile(new Profile());
      user.getProfile().setTakeQuestion(TakeQuestionStatus.NA.value());
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
      if (isEqual(this.getId(), that.getId())
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

  public User setAsIgnoreNull(final User that) {
    if (that == null) {
      return null;
    }

    if (that.getId() != null) {
      this.setId(that.getId());
    }
    if (that.getPwd() != null) {
      this.setPwd(that.getPwd());
    }
    if (that.getFullName() != null && this.getProfile() != null) {
      this.getProfile().setFullName(that.getFullName());
    }

    return this;
  }
}