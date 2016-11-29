package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Profile {
  public enum TakeQuestionStatus {
    FALSE(0, "FALSE"),
    TRUE(1, "TRUE");

    private final int code;
    private final String value;

    TakeQuestionStatus(final int code, final String value) {
      this.code = code;
      this.value = value;
    }

    public int code() {
      return code;
    }

    public String value() {
      return value;
    }
  }

  private String uid;
  /*
   * If Profile.rate filed is initialized to 0 or whatever value, every profile
   * update request will update user's rate to that value even if it's not
   * explicitly specified by client request, which is not expected and will
   * cause data inconsistency.
   */
  private Double rate;
  private String avatarUrl;
  private byte[] avatarImage;
  private String fullName;
  private String title;
  private String aboutMe;
  private String takeQuestion;
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

  public String getTakeQuestion() {
    return takeQuestion;
  }

  public Profile setTakeQuestion(final String takeQuestion) {
    this.takeQuestion = takeQuestion;
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
          && isEqual(this.getAboutMe(), that.getAboutMe())
          && isEqual(this.getTakeQuestion(), that.getTakeQuestion())) {
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
    if (that.getTakeQuestion() != null) {
      this.setTakeQuestion(that.getTakeQuestion());
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

  public static Profile newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    Profile profile = mapper.readValue(json, Profile.class);
    return profile;
  }
}
