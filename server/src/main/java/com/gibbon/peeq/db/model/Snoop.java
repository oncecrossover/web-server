package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Snoop {
  private long id;
  private String uid;
  private long quandaId;
  private Date createdTime;

  public long getId() {
    return id;
  }

  public Snoop setId(final long id) {
    this.id = id;
    return this;
  }

  public String getUid() {
    return uid;
  }

  public Snoop setUid(final String uid) {
    this.uid = uid;
    return this;
  }

  public long getQuandaId() {
    return quandaId;
  }

  public Snoop setQuandaId(final long quandaId) {
    this.quandaId = quandaId;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Snoop setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public static Snoop newSnoop(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    Snoop snoop = mapper.readValue(json, Snoop.class);
    return snoop;
  }

  @Override
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  private String toJsonStr() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }

  public byte[] toJsonByteArray() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsBytes(this);
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
      Snoop snoop = (Snoop) obj;
      if (this.getId() == snoop.getId()
          && this.getUid() == snoop.getUid()
          && this.getQuandaId() == snoop.getQuandaId()) {
        return true;
      }
    }

    return false;
  }

  public Snoop setAsIgnoreNull(final Snoop snoop) {
    if (snoop == null) {
      return this;
    }
    this.setId(snoop.getId());
    if (snoop.getUid() != null) {
      this.setUid(snoop.getUid());
    }
    this.setQuandaId(snoop.getQuandaId());
    this.setCreatedTime(snoop.getCreatedTime());
    return this;
  }
}
