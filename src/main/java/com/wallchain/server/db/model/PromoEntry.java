package com.wallchain.server.db.model;

import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class PromoEntry extends ModelBase implements Model {

  private Long id;
  private Long uid;
  private String code;
  private Integer amount;
  private Date createdTime;
  private Date updatedTime;

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public PromoEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public PromoEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public String getCode() {
    return code;
  }

  public PromoEntry setCode(final String code) {
    this.code = code;
    return this;
  }

  public Integer getAmount() {
    return amount;
  }

  public PromoEntry setAmount(final Integer amount) {
    this.amount = amount;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public PromoEntry setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public PromoEntry setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof PromoEntry) {
      final PromoEntry that = (PromoEntry) obj;
      return isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getCode(), that.getCode())
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
    result = PRIME * result + ((code == null) ? 0 : code.hashCode());
    result = PRIME * result + ((amount == null) ? 0 : amount.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof PromoEntry) {
      final PromoEntry that = (PromoEntry) obj;
      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (that.getUid() != null) {
        this.setUid(that.getUid());
      }
      if (that.getCode() != null) {
        this.setCode(that.getCode());
      }
      if (that.getAmount() != null) {
        this.setAmount(that.getAmount());
      }
    }
  }
}
