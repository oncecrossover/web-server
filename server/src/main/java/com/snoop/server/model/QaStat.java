package com.snoop.server.model;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import com.snoop.server.db.model.Model;
import com.snoop.server.db.model.ModelBase;
import com.snoop.server.model.QaStat;

public class QaStat extends ModelBase implements Model {

  private Long id;
  private Integer snoops;
  private Integer thumbups;
  private Integer thumbdowns;
  private String thumbupped;
  private String thumbdowned;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public QaStat setId(final Long id) {
    this.id = id;
    return this;
  }

  public Integer getSnoops() {
    return snoops;
  }

  public QaStat setSnoops(final Integer snoops) {
    this.snoops = snoops;
    return this;
  }

  public Integer getThumbups() {
    return thumbups;
  }

  public QaStat setThumbups(final Integer thumbups) {
    this.thumbups = thumbups;
    return this;
  }

  public Integer getThumbdowns() {
    return thumbdowns;
  }

  public QaStat setThumbdowns(final Integer thumbdowns) {
    this.thumbdowns = thumbdowns;
    return this;
  }

  public String getThumbupped() {
    return thumbupped;
  }

  public QaStat setThumbupped(final String thumbupped) {
    this.thumbupped = thumbupped;
    return this;
  }

  public String getThumbdowned() {
    return thumbdowned;
  }

  public QaStat setThumbdowned(final String thumbdowned) {
    this.thumbdowned = thumbdowned;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof QaStat) {
      final QaStat that = (QaStat) obj;
      return
          isEqual(this.getId(), that.getId())
          && isEqual(this.getSnoops(), that.getSnoops())
          && isEqual(this.getThumbups(), that.getThumbups())
          && isEqual(this.getThumbdowns(), that.getThumbdowns())
          && isEqual(this.getThumbupped(), that.getThumbupped())
          && isEqual(this.getThumbdowned(), that.getThumbdowned());
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((snoops == null) ? 0 : snoops.hashCode());
    result = PRIME * result + ((thumbups == null) ? 0 : thumbups.hashCode());
    result = PRIME * result
        + ((thumbdowns == null) ? 0 : thumbdowns.hashCode());
    result = PRIME * result
        + ((this.thumbupped == null) ? 0 : thumbupped.hashCode());
    result = PRIME * result
        + ((this.thumbdowned == null) ? 0 : thumbdowned.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
  }
}
