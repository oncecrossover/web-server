package com.gibbon.peeq.db.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Balance {
  private String uid;
  private long val;
  @JsonIgnore
  private User user;

  public String getUid() {
    return uid;
  }

  public Balance setUid(final String uid) {
    this.uid = uid;
    return this;
  }

  public long getVal() {
    return val;
  }

  public Balance setVal(final long val) {
    this.val = val;
    return this;
  }

  public User getUser() {
    return user;
  }

  public Balance setUser(final User user) {
    this.user = user;
    return this;
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
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
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
      Balance balance = (Balance) obj;
      if (this.getUid() == balance.getUid()
          && this.getVal() == balance.getVal()) {
        return true;
      }
    }

    return false;
  }

  public Balance setAsIgnoreNull(final Balance balance) {
    if ( balance == null) {
      return this;
    }

    if (balance.getUid() != null) {
      this.setUid(balance.getUid());
    }

    return this;
  }
}
