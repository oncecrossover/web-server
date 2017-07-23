package com.snoop.server.db.model;

import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class CatMappingEntry extends ModelBase implements Model {

  public enum Status {
    YES(0, "YES"),
    NO(1, "NO");

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

  private Long id;
  private Long catId;
  private String catName;
  private String catDescription;
  private Long uid;
  private String isExpertise;
  private String isInterest;
  private Date createdTime;
  private Date updatedTime;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public CatMappingEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getCatId() {
    return catId;
  }

  public CatMappingEntry setCatId(final Long catId) {
    this.catId = catId;
    return this;
  }

  public String getCatName() {
    return catName;
  }

  public CatMappingEntry setCatName(final String catName) {
    this.catName = catName;
    return this;
  }

  public String getCatDescription() {
    return catDescription;
  }

  public CatMappingEntry stCatDescription(final String catDescription) {
    this.catDescription = catDescription;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public CatMappingEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public String getIsExpertise() {
    return isExpertise;
  }
  public CatMappingEntry setIsExpertise(final String isExpertise) {
    this.isExpertise = isExpertise;
    return this;
  }

  public String getIsInterest() {
    return isInterest;

}
  public CatMappingEntry setIsInterest(final String isInterest) {
    this.isInterest = isInterest;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public CatMappingEntry setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return this.updatedTime;
  }

  public CatMappingEntry setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof CatMappingEntry) {
      final CatMappingEntry that = (CatMappingEntry) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getCatId(), that.getCatId())
          && isEqual(this.getCatName(), that.getCatName())
          && isEqual(this.getCatDescription(), that.getCatDescription())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getIsExpertise(), that.getIsExpertise())
          && isEqual(this.getIsInterest(), that.getIsInterest())
          && isEqual(this.getCreatedTime(), that.getCreatedTime())
          && isEqual(this.getUpdatedTime(), that.getUpdatedTime())) {
        return true;
      }
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((catId == null) ? 0 : catId.hashCode());
    result = PRIME * result + ((catName == null) ? 0 : catName.hashCode());
    result = PRIME * result + ((catDescription == null) ? 0 : catDescription.hashCode());
    result = PRIME * result + ((uid == null) ? 0 : uid.hashCode());
    result = PRIME * result
        + ((isExpertise == null) ? 0 : isExpertise.hashCode());
    result = PRIME * result
        + ((isInterest == null) ? 0 : isInterest.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(final T obj) {
    if (obj instanceof CatMappingEntry) {
      final CatMappingEntry that = (CatMappingEntry)obj;
      if (that.getCatId() != null) {
        this.setCatId(that.getCatId());
      }
      if (that.getUid() != null) {
        this.setUid(that.getUid());
      }
      if (that.getIsExpertise() != null) {
        this.setIsExpertise(that.getIsExpertise());
      }
      if (that.getIsInterest() != null) {
        this.setIsInterest(that.getIsInterest());
      }
    }
  }

}
