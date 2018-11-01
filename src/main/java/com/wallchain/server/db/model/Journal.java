package com.wallchain.server.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class Journal {

  public static class JournalType extends EnumBase {
    public static final JournalType BALANCE = new JournalType(0, "BALANCE");
    public static final JournalType CARD = new JournalType(1, "CARD");
    public static final JournalType BANKING = new JournalType(2, "BANKING");
    public static final JournalType COIN = new JournalType(3, "COIN");

    public JournalType(final int code, final String value) {
      super(code, value);
    }
  }

  public static class Status extends EnumBase {
    public static final Status PENDING  = new Status(0, "PENDING");
    public static final Status CLEARED = new Status(1, "CLEARED");
    public static final Status REFUNDED = new Status(2, "REFUNDED");
    public Status(final int code, final String value) {
      super(code, value);
    }
  }

  private Long id;
  private Long transactionId;
  private Long uid;
  private Double amount;
  private String type;
  private String status;
  private String chargeId;
  private Long coinEntryId;
  private Long originId;
  private Date createdTime;


  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public Journal setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getTransactionId() {
    return transactionId;
  }

  public Journal setTransactionId(final Long transactionId) {
    this.transactionId = transactionId;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public Journal setUid(final Long uid) {
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

  public String getStatus() {
    return status;
  }

  public Journal setStatus(final String status) {
    this.status = status;
    return this;
  }

  public String getChargeId() {
    return chargeId;
  }

  public Journal setChargeId(final String chargeId) {
    this.chargeId = chargeId;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getCoinEntryId() {
    return coinEntryId;
  }

  public Journal setCoinEntryId(final Long coinEntryId) {
    this.coinEntryId = coinEntryId;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getOriginId() {
    return originId;
  }

  public Journal setOriginId(final Long originId) {
    this.originId = originId;
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
      if (isEqual(this.getId(), that.getId()) &&
          isEqual(this.getTransactionId(), that.getTransactionId()) &&
          isEqual(this.getUid(), that.getUid()) &&
          isEqual(this.getAmount(), that.getAmount()) &&
          isEqual(this.getType(), that.getType()) &&
          isEqual(this.getChargeId(), that.getChargeId()) &&
          isEqual(this.getStatus(), that.getStatus()) &&
          isEqual(this.getOriginId(), that.getOriginId())) {
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
    if (that.getOriginId() != null) {
      this.setOriginId(that.getOriginId());
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
