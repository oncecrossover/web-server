package com.wallchain.server.db.model;

import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class CoinEntry extends ModelBase implements Model {
  private Long id;
  private Long uid;
  private Integer amount;
  private Long originId;
  private Long promoId;
  private Date createdTime;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public CoinEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
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

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getOriginId() {
    return originId;
  }

  public CoinEntry setOriginId(final Long originId) {
    this.originId = originId;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getPromoId() {
    return promoId;
  }

  public CoinEntry setPromoId(final Long promoId) {
    this.promoId = promoId;
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
          && isEqual(this.getOriginId(), that.getOriginId())
          && isEqual(this.getPromoId(), that.getPromoId())
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
    result = PRIME * result + ((originId == null) ? 0 : originId.hashCode());
    result = PRIME * result + ((promoId == null) ? 0 : promoId.hashCode());
    result = PRIME * result + ((createdTime == null) ? 0 : createdTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof CoinEntry) {
      final CoinEntry that = (CoinEntry) obj;
      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (that.getUid() != null) {
        this.setUid(that.getUid());
      }
      if (that.getAmount() != null) {
        this.setAmount(that.getAmount());
      }
      if (that.getOriginId() != null) {
        this.setOriginId(that.getOriginId());
      }
      if (that.getPromoId() != null) {
        this.setPromoId(that.getPromoId());
      }
    }
  }
}
