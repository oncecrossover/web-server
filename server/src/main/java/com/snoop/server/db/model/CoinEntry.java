package com.snoop.server.db.model;

import java.util.Date;

public class CoinEntry extends ModelBase implements Model {
  private Long id;
  private Long uid;
  private Integer amount;
  private Long originId;
  private Date createdTime;

  public Long getId() {
    return id;
  }

  public CoinEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  public Long getUid() {
    return uid;
  }

  public CoinEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public Integer getAmount() {
    return amount;
  }

  public CoinEntry setAmount(final Integer amount) {
    this.amount = amount;
    return this;
  }

  public Long getOriginId() {
    return originId;
  }

  public CoinEntry setOriginId(final Long originId) {
    this.originId = originId;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public CoinEntry setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof CoinEntry) {
      final CoinEntry that = (CoinEntry) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getAmount(), that.getAmount())
          && isEqual(this.getCreatedTime(), that.getCreatedTime())) {
        return true;
      }
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((uid == null) ? 0 : uid.hashCode());
    result = PRIME * result + ((amount == null) ? 0 : amount.hashCode());
    result = PRIME * result + ((createdTime == null) ? 0 : createdTime.hashCode());
    return result;
  }
}
