package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class PcEntry {
  private long id;
  private String uid;
  private String entryId;
  private Date createdTime;

  public long getId() {
    return id;
  }

  public PcEntry setId(final long id) {
    this.id = id;
    return this;
  }

  public String getUid() {
    return uid;
  }

  public PcEntry setUid(final String uid) {
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

  public Date getCreatedTime() {
    return createdTime;
  }

  public PcEntry setCreatedTime(final Date createdTime) {
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
      final PcEntry that = (PcEntry) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getEntryId(), that.getEntryId())) {
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
