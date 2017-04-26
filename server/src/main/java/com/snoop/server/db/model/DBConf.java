package com.snoop.server.db.model;

import java.util.Date;

import org.apache.commons.lang3.StringUtils;

public class DBConf extends ModelBase implements Model {
  private Long id;
  private String ckey;
  private String value;
  private String defaultValue;
  private String description;
  private Date createdTime;
  private Date updatedTime;

  public Long getId() {
    return id;
  }

  public DBConf setId(final Long id) {
    this.id = id;
    return this;
  }

  public String getCkey() {
    return ckey;
  }

  public DBConf setCkey(final String ckey) {
    this.ckey = ckey;
    return this;
  }

  public String getValue() {
    return value;
  }

  public DBConf setValue(final String value) {
    this.value = value;
    return this;
  }

  public String getDefaultValue() {
    return defaultValue;
  }

  public DBConf setDefaultValue(final String defaultValue) {
    this.defaultValue = defaultValue;
    return this;
  }

  public String getDescription() {
    return description;
  }

  public DBConf setDescription(final String description) {
    this.description = description;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public DBConf setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return this.updatedTime;
  }

  public DBConf setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof DBConf) {
      final DBConf that = (DBConf) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getCkey(), that.getCkey())
          && isEqual(this.getValue(), that.getValue())
          && isEqual(this.getDefaultValue(), that.getDefaultValue())
          && isEqual(this.getDescription(), that.getDescription())
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
    result = PRIME * result + ((ckey == null) ? 0 : ckey.hashCode());
    result = PRIME * result + ((value == null) ? 0 : value.hashCode());
    result = PRIME * result
        + ((defaultValue == null) ? 0 : defaultValue.hashCode());
    result = PRIME * result
        + ((description == null) ? 0 : description.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof DBConf) {
      final DBConf that = (DBConf) obj;
      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (!StringUtils.isBlank(that.getCkey())) {
        this.setCkey(that.getCkey());
      }
      if (!StringUtils.isBlank(that.getValue())) {
        this.setValue(that.getValue());
      }
      if (!StringUtils.isBlank(that.getDefaultValue())) {
        this.setDefaultValue(that.getDefaultValue());
      }
      if (!StringUtils.isBlank(that.getDescription())) {
        this.setDescription(that.getDescription());
      }
    }
  }
}
