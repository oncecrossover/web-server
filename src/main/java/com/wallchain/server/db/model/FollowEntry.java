package com.wallchain.server.db.model;

import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class FollowEntry extends ModelBase implements Model {

  private Long id;
  private Long uid;
  private Long followeeId;
  private String followed;
  private Date createdTime;
  private Date updatedTime;

  public enum FollowStatus {
    FALSE(0, "FALSE"), TRUE(1, "TRUE");

    private final int code;
    private final String value;

    FollowStatus(final int code, final String value) {
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

  public FollowEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public FollowEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getFolloweeId() {
    return followeeId;
  }

  public FollowEntry setFolloweeId(final Long followeeId) {
    this.followeeId = followeeId;
    return this;
  }

  public String getFollowed() {
    return followed;
  }

  public FollowEntry setFollowed(final String followed) {
    this.followed = followed;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public FollowEntry setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public FollowEntry setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof FollowEntry) {
      final FollowEntry that = (FollowEntry) obj;
      return isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getFolloweeId(), that.getFolloweeId())
          && isEqual(this.getFollowed(), that.getFollowed())
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
    result = PRIME * result + ((followeeId == null) ? 0 : followeeId.hashCode());
    result = PRIME * result + ((followed == null) ? 0 : followed.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof FollowEntry) {
      final FollowEntry that = (FollowEntry) obj;
      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (that.getUid() != null) {
        this.setUid(that.getUid());
      }
      if (that.getFolloweeId() != null) {
        this.setFolloweeId(that.getFolloweeId());
      }
      if (that.getFollowed() != null) {
        this.setFollowed(that.getFollowed());
      }
    }
  }
}
