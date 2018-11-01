package com.wallchain.server.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class TempPwd {
  private Long id;
  private Long uid;
  private String uname;
  private String pwd;
  private String status;
  private Date createdTime;
  private Date updatedTime;

  public enum Status {
    PENDING(0, "PENDING"),
    EXPIRED(1, "EXPIRED");

    private final int code;
    private final String value;

    Status(final int code, final String value) {
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

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public TempPwd setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public TempPwd setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public String getUname() {
    return uname;
  }

  public TempPwd setUname(final String uname) {
    this.uname = uname;
    return this;
  }

  public String getPwd() {
    return pwd;
  }

  public TempPwd setPwd(final String pwd) {
    this.pwd = pwd;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public TempPwd setStatus(final String status) {
    this.status = status;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public TempPwd setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public TempPwd setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public static TempPwd newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    TempPwd tempPwd = mapper.readValue(json, TempPwd.class);
    return tempPwd;
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
      TempPwd that = (TempPwd) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getPwd(), that.getPwd())
          && isEqual(this.getStatus(), that.getStatus())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public TempPwd setAsIgnoreNull(final TempPwd tempPwd) {
    if (tempPwd == null) {
      return this;
    }
    if (tempPwd.getId() != null) {
      this.setId(tempPwd.getId());
    }
    if (tempPwd.getUid() != null) {
      this.setUid(tempPwd.getUid());
    }
    if (tempPwd.getPwd() != null) {
      this.setPwd(tempPwd.getPwd());
    }
    if (tempPwd.getStatus() != null) {
      this.setStatus(tempPwd.getStatus());
    }
    return this;
  }
}
