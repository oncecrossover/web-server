package com.wallchain.server.db.model;

import java.util.Date;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class BlockEntry extends ModelBase implements Model {

  private Long id;
  private Long uid;
  private Long blockeeId;
  private String blocked;
  private Date createdTime;
  private Date updatedTime;

  public enum BlockStatus {
    FALSE(0, "FALSE"), TRUE(1, "TRUE");

    private final int code;
    private final String value;

    BlockStatus(final int code, final String value) {
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

  public BlockEntry setId(final Long id) {
    this.id = id;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public BlockEntry setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  @JsonSerialize(using = ToStringSerializer.class)
  public Long getBlockeeId() {
    return blockeeId;
  }

  public BlockEntry setBlockeeId(final Long blockeeId) {
    this.blockeeId = blockeeId;
    return this;
  }

  public String getBlocked() {
    return blocked;
  }

  public BlockEntry setBlocked(final String blocked) {
    this.blocked = blocked;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public BlockEntry setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public BlockEntry setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof BlockEntry) {
      final BlockEntry that = (BlockEntry) obj;
      return isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getBlockeeId(), that.getBlockeeId())
          && isEqual(this.getBlocked(), that.getBlocked())
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
    result = PRIME * result + ((blockeeId == null) ? 0 : blockeeId.hashCode());
    result = PRIME * result + ((blocked == null) ? 0 : blocked.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof BlockEntry) {
      final BlockEntry that = (BlockEntry) obj;
      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (that.getUid() != null) {
        this.setUid(that.getUid());
      }
      if (that.getBlockeeId() != null) {
        this.setBlockeeId(that.getBlockeeId());
      }
      if (that.getBlocked() != null) {
        this.setBlocked(that.getBlocked());
      }
    }
  }
}
