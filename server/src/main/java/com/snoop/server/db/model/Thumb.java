package com.snoop.server.db.model;

import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class Thumb extends ModelBase implements Model {

  private Long id;
  private Long uid;
  private Long quandaId;
  private String upped;
  private String downed;
  private Date createdTime;
  private Date updatedTime;

  public enum ThumbStatus {
    FALSE(0, "FALSE"), TRUE(1, "TRUE");

    private final int code;
    private final String value;

    ThumbStatus(final int code, final String value) {
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

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public Thumb setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public Thumb setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getQuandaId() {
    return quandaId;
  }

  public Thumb setQuandaId(final Long quandaId) {
    this.quandaId = quandaId;
    return this;
  }

  public String getUpped() {
    return upped;
  }

  public Thumb setUpped(final String upped) {
    this.upped = upped;
    return this;
  }

  public String getDowned() {
    return downed;
  }

  public Thumb setDowned(final String downed) {
    this.downed = downed;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Thumb setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public Thumb setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof Thumb) {
      final Thumb that = (Thumb) obj;
      return isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getQuandaId(), that.getQuandaId())
          && isEqual(this.getUpped(), that.getUpped())
          && isEqual(this.getDowned(), that.getDowned())
          && isEqual(this.getCreatedTime(), that.getCreatedTime())
          && isEqual(this.getUpdatedTime(), that.getUpdatedTime());
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((uid == null) ? 0 : uid.hashCode());
    result = PRIME * result + ((quandaId == null) ? 0 : quandaId.hashCode());
    result = PRIME * result + ((upped == null) ? 0 : upped.hashCode());
    result = PRIME * result + ((downed == null) ? 0 : downed.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof Thumb) {
      final Thumb that = (Thumb) obj;
      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (that.getUid() != null) {
        this.setUid(that.getUid());
      }
      if (that.getQuandaId() != null) {
        this.setQuandaId(that.getQuandaId());
      }
      if (that.getUpped() != null) {
        this.setUpped(that.getUpped());
      }
      if (that.getDowned() != null) {
        this.setDowned(that.getDowned());
      }
    }
  }
}
