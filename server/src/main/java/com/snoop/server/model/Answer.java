package com.snoop.server.model;

import java.util.Date;

public class Answer extends Activity {

  private Date updatedTime;

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public Answer setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof Answer) {
      Answer that = (Answer) obj;
      return super.equals(obj)
          && isEqual(this.getUpdatedTime(), that.getUpdatedTime());
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = super.hashCode();
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    return result;
  }
}
