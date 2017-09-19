package com.snoop.server.db.model;

import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class ReportEntry extends ModelBase implements Model {

  private Long id;
  private Long uid;
  private Long quandaId;
  private Date createdTime;

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public ReportEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public ReportEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getQuandaId() {
    return quandaId;
  }

  public ReportEntry setQuandaId(final Long quandaId) {
    this.quandaId = quandaId;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public ReportEntry setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof ReportEntry) {
      final ReportEntry that = (ReportEntry) obj;
      return isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getQuandaId(), that.getQuandaId())
          && isEqual(this.getCreatedTime(), that.getCreatedTime());
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((uid == null) ? 0 : uid.hashCode());
    result = PRIME * result + ((quandaId == null) ? 0 : quandaId.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
  }
}
