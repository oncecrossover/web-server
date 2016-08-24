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

  public enum JournalStatus {
    PENDING(0, "PENDING"),
    CLEARED(1, "CLEARED"),
    REFUNDED(2, "REFUNDED");

    private final int code;
    private final String value;

    JournalStatus(final int code, final String value) {
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

  private Long id;
  private Long transactionId;
  private String uid;
  private Double amount;
  private String type;
  private String chargeId;
  private String status;
  private Long origineId;
  private Date createdTime;


  public Long getId() {
    return id;
  }

  public Journal setId(final Long id) {
    this.id = id;
    return this;
  }

  public Long getTransactionId() {
    return transactionId;
  }

  public Journal setTransactionId(final Long transactionId) {
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

  public String getChargeId() {
    return chargeId;
  }

  public Journal setChargeId(final String chargeId) {
    this.chargeId = chargeId;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Journal setStatus(final String status) {
    this.status = status;
    return this;
  }

  public Long getOrigineId() {
    return origineId;
  }

  public Journal setOrigineId(final Long origineId) {
    this.origineId = origineId;
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

    if (that.getId() != null) {
      this.setId(that.getId());
    }
    if (that.getTransactionId() != null) {
      this.setTransactionId(that.getTransactionId());
    }
    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    if (that.getAmount() != null) {
      this.setAmount(that.getAmount());
    }
    if (that.getType() != null) {
      this.setType(that.getType());
    }
    if (that.getChargeId() != null) {
      this.setChargeId(that.getChargeId());
    }
    if (that.getStatus() != null) {
      this.setStatus(that.getStatus());
    }
    if (that.getOrigineId() != null) {
      this.setOrigineId(that.getOrigineId());
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
