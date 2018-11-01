package com.wallchain.server.db.model;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class TakeQuestionRequest extends ModelBase implements Model {

  private Long uid;
  private String takeQuestion;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getUid() {
    return uid;
  }

  public TakeQuestionRequest setUid(final Long uid) {
    this.uid = uid;
    return this;
  }

  public String getTakeQuestion() {
    return takeQuestion;
  }

  public TakeQuestionRequest setTakeQuestion(final String takeQuestion) {
    this.takeQuestion = takeQuestion;
    return this;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof TakeQuestionRequest) {
      final TakeQuestionRequest that = (TakeQuestionRequest) obj;
      if (isEqual(this.getUid(), that.getUid())
          && isEqual(this.getTakeQuestion(), that.getTakeQuestion())) {
        return true;
      }
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((uid == null) ? 0 : uid.hashCode());
    result = PRIME * result
        + ((takeQuestion == null) ? 0 : takeQuestion.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(final T obj) {
    if (obj instanceof TakeQuestionRequest) {
      final TakeQuestionRequest that = (TakeQuestionRequest) obj;
      if (that.getUid() != null) {
        this.setUid(that.getUid());
      }
      if (that.getTakeQuestion() != null) {
        this.setTakeQuestion(that.getTakeQuestion());
      }
    }
  }
}
