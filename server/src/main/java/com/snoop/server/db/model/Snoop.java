package com.snoop.server.db.model;

import com.snoop.server.model.Activity;

public class Snoop extends Activity {

  private Long uid;
  private Long quandaId;

  public Long getUid() {
    return uid;
  }

  public Snoop setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public Long getQuandaId() {
    return quandaId;
  }

  public Snoop setQuandaId(final Long quandaId) {
    this.quandaId = quandaId;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof Snoop) {
      Snoop that = (Snoop) obj;
      return super.equals(obj) && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getQuandaId(), that.getQuandaId());
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = super.hashCode();
    result = PRIME * result + ((uid == null) ? 0 : uid.hashCode());
    result = PRIME * result + ((quandaId == null) ? 0 : quandaId.hashCode());
    return result;
  }
}
