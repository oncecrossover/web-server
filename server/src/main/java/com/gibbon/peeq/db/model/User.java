package com.gibbon.peeq.db.model;

import java.util.Date;

import org.apache.commons.lang3.StringUtils;

public class User {

  private int id;
  private String uid;
  private String firstName;
  private String middleName;
  private String lastName;
  private String pwd;
  private Date insertTime;

  public int getId() {
    return id;
  }

  public void setId(int id) {
    this.id = id;
  }

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

  @Override
  public String toString() {
    if (StringUtils.isBlank(middleName)) {
      return String.format("%d, %s, %s %s, %s, %s,", id, uid, firstName,
          lastName, pwd, insertTime);
    } else {
      return String.format("%d, %s, %s %s %s, %s, %s,", id, uid, firstName,
          middleName, lastName, pwd, insertTime);
    }
  }
}