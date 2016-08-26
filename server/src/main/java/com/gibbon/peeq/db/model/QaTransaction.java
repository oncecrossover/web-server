package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class QaTransaction {
  public enum TransType {
    ASKED, SNOOPED
  }

  private Long id;
  private String uid;
  private String type;
  private Long quandaId;
  private Double amount;
  private Date createdTime;
  private Quanda quanda;

  public Long getId() {
    return id;
  }

  public QaTransaction setId(final Long id) {
    this.id = id;
    return this;
  }

  public String getUid() {
    return uid;
  }

  public QaTransaction setUid(final String uid) {
    this.uid = uid;
    return this;
  }

  public String getType() {
    return type;
  }

  public QaTransaction setType(final String type) {
    this.type = type;
    return this;
  }

  public Long getQuandaId() {
    return quandaId;
  }

  public QaTransaction setQuandaId(final Long quandaId) {
    this.quandaId = quandaId;
    return this;
  }

  public Double getAmount() {
    return amount;
  }

  public QaTransaction setAmount(final double amount) {
    this.amount = amount;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public QaTransaction setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Quanda getquanda() {
    return quanda;
  }

  public QaTransaction setquanda(final Quanda quanda) {
    this.quanda = quanda;
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
      final QaTransaction that = (QaTransaction) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getType(), that.getType())
          && isEqual(this.getQuandaId(), that.getQuandaId())
          && isEqual(this.getAmount(), that.getAmount())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public QaTransaction setAsIgnoreNull(final QaTransaction that) {
    if (that == null) {
      return null;
    }

    if (that.getId() != null) {
      this.setId(that.getId());
    }
    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    if (that.getType() != null) {
      this.setType(that.getType());
    }
    if (that.getQuandaId() != null) {
      this.setQuandaId(that.getQuandaId());
    }
    if (that.getAmount() != null) {
      this.setAmount(that.getAmount());
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

  public static QaTransaction newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    final QaTransaction result = mapper.readValue(json, QaTransaction.class);
    return result;
  }
}
