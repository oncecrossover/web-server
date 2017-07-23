package com.snoop.server.model;

import java.io.IOException;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class Balance {
  private Long uid;
  private Double balance;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }
  public Balance setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public Double getBalance() {
    return balance;
  }
  public Balance setBalance(final Double balance) {
    this.balance = balance;
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
      final Balance that = (Balance) obj;
      if (isEqual(this.getUid(), that.getUid())
          && isEqual(this.getBalance(), that.getBalance())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public Balance setAsIgnoreNull(final Balance that) {
    if (that == null) {
      return null;
    }

    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    if (that.getBalance() != null) {
      this.setBalance(that.getBalance());
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

  public static Balance newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    final Balance result = mapper.readValue(json, Balance.class);
    return result;
  }
}
