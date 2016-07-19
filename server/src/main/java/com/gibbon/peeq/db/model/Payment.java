package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Payment {
  public enum PaymentType {
    CHECKING, CARD
  }
  private long id;
  private String uid;
  private String accId;
  private String type;
  private String lastFour;
  @JsonIgnore
  private Date createdTime;

  public long getId() {
    return id;
  }

  public Payment setId(final long id) {
    this.id = id;
    return this;
  }

  public String getUid() {
    return uid;
  }

  public Payment setUid(final String uid) {
    this.uid = uid;
    return this;
  }

  public String getAccId() {
    return accId;
  }

  public Payment setAccId(final String accId) {
    this.accId = accId;
    return this;
  }

  public String getType() {
    return type;
  }

  public Payment setType(final String type) {
    this.type = type;
    return this;
  }

  public String getLastFour() {
    return lastFour;
  }

  public Payment setLastFour(final String lastFour) {
    this.lastFour = lastFour;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Payment setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
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
      Payment payment = (Payment) obj;
      if (this.getId() == payment.getId()
          && this.getUid() == payment.getUid()
          && this.getAccId() == payment.getAccId()
          && this.getType() == payment.getType()
          && this.getLastFour() == payment.getLastFour()) {
        return true;
      }
    }

    return false;
  }

  public static Payment newPayment(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    Payment result = mapper.readValue(json, Payment.class);
    return result;
  }

  public Payment setAsIgnoreNull(final Payment payment) {
    if ( payment == null) {
      return this;
    }

    this.setId(payment.getId());
    if (payment.getUid() != null) {
      this.setUid(payment.getUid());
    }
    if (payment.getAccId() != null) {
      this.setAccId(payment.getAccId());
    }
    if (payment.getType() != null) {
      this.setType(payment.getType());
    }
    if (payment.getLastFour() != null) {
      this.setLastFour(payment.getLastFour());
    }
    if (payment.getCreatedTime() != null) {
      this.setCreatedTime(payment.getCreatedTime());
    }
    return this;
  }
}