package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Profile {
  private String uid;
  private Double rate = 0.0;
  private String avatarUrl;
  private byte[] avatarImage;
  private String fullName;
  private String title;
  private String aboutMe;
  private Date createdTime;
  private Date updatedTime;
  @JsonIgnore
  private User user;

  public String getUid() {
    return uid;
  }

  public Profile setUid(final String uid) {
    this.uid = uid;
    return this;
  }


  public Double getRate() {
    return rate;
  }

  public Profile setRate(final Double rate) {
    this.rate = rate;
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

  public Date getCreatedTime() {
    return createdTime;
  }

  public Profile setCreatedTime(Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public Profile setUpdatedTime(Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public User getUser() {
    return user;
  }

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
      Profile that = (Profile) obj;
      if (isEqual(this.getUid(), that.getUid())
          && isEqual(this.getRate(), that.getRate())
          && isEqual(this.getAvatarUrl(), that.getAvatarUrl())
          && isEqual(this.getFullName(), that.getFullName())
          && isEqual(this.getTitle(), that.getTitle())
          && isEqual(this.getAboutMe(), that.getAboutMe())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public Profile setAsIgnoreNull(final Profile that) {
    if (that == null) {
      return null;
    }

    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    if (that.getRate() != null) {
      this.setRate(that.getRate());
    }
    if (that.getAvatarUrl() != null) {
      this.setAvatarUrl(that.getAvatarUrl());
    }
    if (that.getAvatarImage() != null) {
      this.setAvatarImage(that.getAvatarImage());
    }
    if (that.getFullName() != null) {
      this.setFullName(that.getFullName());
    }
    if (that.getTitle() != null) {
      this.setTitle(that.getTitle());
    }
    if (that.getAboutMe() != null) {
      this.setAboutMe(that.getAboutMe());
    }
    return this;
  }

  @Override
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  public byte[] toJsonByteArray() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsBytes(this);
  }

  public String toJsonStr() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }

  public static Profile newProfile(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    Profile profile = mapper.readValue(json, Profile.class);
    return profile;
  }
}
