package com.snoop.server.db.model;

import java.util.Date;

public class Category extends ModelBase implements Model {
  private Long id;
  private String name;
  private String description;
  private Date createdTime;
  private Date updatedTime;

  public Long getId() {
    return id;
  }

  public Category setId(final Long id) {
    this.id = id;
    return this;
  }

  public String getName() {
    return name;
  }

  public Category setName(final String name) {
    this.name = name;
    return this;
  }

  public String getDescription() {
    return description;
  }

  public Category setDescription(final String description) {
    this.description = description;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Category setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return this.updatedTime;
  }

  public Category setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof Category) {
      final Category that = (Category) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getName(), that.getName())
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
    result = PRIME * result + ((name == null) ? 0 : name.hashCode());
    result = PRIME * result + ((description == null) ? 0 : description.hashCode());
    result = PRIME * result + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(final T obj) {
    if (obj instanceof Category) {
      final Category that = (Category)obj;
      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (that.getName() != null) {
        this.setName(that.getName());
      }
      if (that.getDescription() != null) {
        this.setDescription(that.getDescription());
      }
    }
  }
}