package com.gibbon.peeq.db.model;

import com.fasterxml.jackson.annotation.JsonIgnore;

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
}
