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
  private Date insertTime;

  public String getUid() {
    return uid;
  }

  public void setUid(String uid) {
    this.uid = uid;
  }

  public String getFirstName() {
    return this.firstName;
  }

  public void setFirstName(String firstName) {
    this.firstName = firstName;
  }

  public String getMiddleName() {
    return this.middleName;
  }

  public void setMiddleName(String middleName) {
    this.middleName = middleName;
  }

  public String getLastName() {
    return this.lastName;
  }

  public void setLastName(String lastName) {
    this.lastName = lastName;
  }

  public String getPwd() {
    return pwd;
  }

  public void setPwd(String pwd) {
    this.pwd = pwd;
  }

  public Date getInsertTime() {
    return insertTime;
  }

  public void setInsertTime(Date insertTime) {
    this.insertTime = insertTime;
  }

  public static User newUser(final String userJson)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    User user = mapper.readValue(userJson, User.class);
    return user;
  }

  @Override
  public String toString() {
    if (StringUtils.isBlank(middleName)) {
      return String.format("%s, %s %s, %s, %s,", uid, firstName,
          lastName, pwd, insertTime);
    } else {
      return String.format("%s, %s %s %s, %s, %s,", uid, firstName,
          middleName, lastName, pwd, insertTime);
    }
  }

  public String toJson() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }
}