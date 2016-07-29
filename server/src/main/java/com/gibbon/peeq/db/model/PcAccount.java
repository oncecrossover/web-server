package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class PcAccount {
  private String uid;
  private String chargeFrom;
  private String payTo;
  private Date createdTime;
  private Date updatedTime;
  @JsonIgnore
  private User user;

  public String getUid() {
    return uid;
  }

  public PcAccount setUid(final String uid) {
    this.uid = uid;
    return this;
  }

  public String getChargeFrom() {
    return chargeFrom;
  }

  public PcAccount setChargeFrom(final String chargeFrom) {
    this.chargeFrom = chargeFrom;
    return this;
  }

  public String getPayTo() {
    return payTo;
  }

  public PcAccount setPayTo(final String payTo) {
    this.payTo = payTo;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public PcAccount setCreatedTime(Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public PcAccount setUpdatedTime(Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public User getUser() {
    return user;
  }

  public PcAccount setUser(final User user) {
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
      final PcAccount that = (PcAccount) obj;
      if (isEqual(this.getUid(), that.getUid())
          && isEqual(this.getChargeFrom(), that.getChargeFrom())
          && isEqual(this.getPayTo(), that.getPayTo())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public PcAccount setAsIgnoreNull(final PcAccount that) {
    if (that == null) {
      return null;
    }

    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    if (that.getChargeFrom() != null) {
      this.setChargeFrom(that.getChargeFrom());
    }
    if (that.getPayTo() != null) {
      this.setPayTo(that.getPayTo());
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

  public static PcAccount newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    final PcAccount result = mapper.readValue(json, PcAccount.class);
    return result;
  }
}
