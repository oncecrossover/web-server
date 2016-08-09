package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Journal {
  public enum JournalType {
    BALANCE, CARD, BANKING
  }

  private long id;
  private long transactionId;
  private String uid;
  private Double amount;
  private String type;
  private Date createdTime;


  public long getId() {
    return id;
  }

  public Journal setId(final long id) {
    this.id = id;
    return this;
  }

  public long getTransactionId() {
    return transactionId;
  }

  public Journal setTransactionId(final long transactionId) {
    this.transactionId = transactionId;
    return this;
  }

  public String getUid() {
    return uid;
  }

  public Journal setUid(final String uid) {
    this.uid = uid;
    return this;
  }

  public Double getAmount() {
    return amount;
  }

  public Journal setAmount(final double amount) {
    this.amount = amount;
    return this;
  }

  public String getType() {
    return type;
  }

  public Journal setType(final String type) {
    this.type = type;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Journal setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
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
      final Journal that = (Journal) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getTransactionId(), that.getTransactionId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getAmount(), that.getAmount())
          && isEqual(this.getType(), that.getType())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public Journal setAsIgnoreNull(final Journal that) {
    if (that == null) {
      return null;
    }

    this.setId(that.getId());
    this.setTransactionId(that.getTransactionId());
    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    if (that.getAmount() != null) {
      this.setAmount(that.getAmount());
    }
    if (that.getType() != null) {
      this.setType(that.getType());
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

  public static Journal newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    final Journal result = mapper.readValue(json, Journal.class);
    return result;
  }
}
