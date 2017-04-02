package com.snoop.server.model;

import java.io.IOException;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class PwdEntry {

  private Long uid;
  private String tempPwd;
  private String newPwd;

  public Long getUid() {
    return uid;
  }

  public PwdEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public String getTempPwd() {
    return tempPwd;
  }

  public PwdEntry setTempPwd(final String tempPwd) {
    this.tempPwd = tempPwd;
    return this;
  }

  public String getNewPwd() {
    return newPwd;
  }

  public PwdEntry setNewPwd(final String newPwd) {
    this.newPwd = newPwd;
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
      final PwdEntry that = (PwdEntry) obj;
      if (isEqual(this.getUid(), that.getUid())
          && isEqual(this.getTempPwd(), that.getTempPwd())
          && isEqual(this.getNewPwd(), that.getNewPwd())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
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

  public static PwdEntry newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    final PwdEntry result = mapper.readValue(json, PwdEntry.class);
    return result;
  }
}
