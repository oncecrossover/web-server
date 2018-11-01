package com.wallchain.server.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class PcEntry {
  private Long id;
  private Long uid;
  private String entryId;
  private String brand;
  private String last4;
  private String token;
  private Date createdTime;
  private Boolean isDefault = false;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public PcEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public PcEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public String getEntryId() {
    return entryId;
  }

  public PcEntry setEntryId(final String entryId) {
    this.entryId = entryId;
    return this;
  }

  public String getBrand() {
    return brand;
  }

  public PcEntry setBrand(final String brand) {
    this.brand = brand;
    return this;
  }

  public String getLast4() {
    return last4;
  }

  public PcEntry setLast4(final String last4) {
    this.last4 = last4;
    return this;
  }

  public String getToken() {
    return token;
  }

  public PcEntry setToken(final String token) {
    this.token = token;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public PcEntry setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Boolean getDefault() {
    return isDefault;
  }

  public PcEntry setDefault(final Boolean isDefault) {
    this.isDefault = isDefault;
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
      final PcEntry that = (PcEntry) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getEntryId(), that.getEntryId())
          && isEqual(this.getBrand(), that.getBrand())
          && isEqual(this.getLast4(), that.getLast4())
          && isEqual(this.getDefault(), that.getDefault())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public PcEntry setAsIgnoreNull(final PcEntry that) {
    if (that == null) {
      return null;
    }

    this.setId(that.getId());
    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    if (that.getEntryId() != null) {
      this.setEntryId(that.getEntryId());
    }
    if (that.getBrand() != null) {
      this.setBrand(that.getBrand());
    }
    if (that.getLast4() != null) {
      this.setLast4(that.getLast4());
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

  public static PcEntry newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    final PcEntry result = mapper.readValue(json, PcEntry.class);
    return result;
  }
}
