package com.snoop.server.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class PcAccount extends ModelBase implements Model {
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

    if (obj instanceof PcAccount) {
      final PcAccount that = (PcAccount) obj;
      if (isEqual(this.getUid(), that.getUid())
          && isEqual(this.getChargeFrom(), that.getChargeFrom())
          && isEqual(this.getPayTo(), that.getPayTo())
          && isEqual(this.getCreatedTime(), that.getCreatedTime())
          && isEqual(this.getUpdatedTime(), that.getUpdatedTime())) {
        return true;
      }
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((uid == null) ? 0 : uid.hashCode());
    result = PRIME * result
        + ((chargeFrom == null) ? 0 : chargeFrom.hashCode());
    result = PRIME * result + ((payTo == null) ? 0 : payTo.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());

    return result;
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
}