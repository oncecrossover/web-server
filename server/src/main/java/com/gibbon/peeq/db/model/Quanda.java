package com.gibbon.peeq.db.model;

import java.util.Date;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Quanda {
  public enum QnaStatus {
    PENDING, ANSWERED, EXPIRED
  }

  private long qid;
  private String asker;
  private String question;
  private String responder;
  private String answerUrl;
  private String status;
  private Date createdTime;
  private Date updatedTime;

  public long getQid() {
    return qid;
  }

  public Quanda setQid(final long qid) {
    this.qid = qid;
    return this;
  }

  public String getAsker() {
    return asker;
  }

  public Quanda setAsker(final String asker) {
    this.asker = asker;
    return this;
  }

  public String getQuestion() {
    return question;
  }

  public Quanda setQuestion(final String question) {
    this.question = question;
    return this;
  }

  public String getResponder() {
    return responder;
  }

  public Quanda setResponder(final String responder) {
    this.responder = responder;
    return this;
  }

  public String getAnswerUrl() {
    return this.answerUrl;
  }

  public Quanda setAnswerUrl(final String answerUrl) {
    this.answerUrl = answerUrl;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Quanda setStatus(final String status) {
    this.status = status;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Quanda setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return this.updatedTime;
  }

  public Quanda setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  @Override
  public String toString() {
    try {
      return toJson();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  public String toJson() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj == null) {
      return false;
    }

    if (getClass() == obj.getClass()) {
      Quanda qanda = (Quanda) obj;
      if (this.getQid() == qanda.getQid()
          && this.getAsker() == qanda.getAsker()
          && this.getQuestion() == qanda.getQuestion()
          && this.getResponder() == qanda.getResponder()
          && this.getAnswerUrl() == qanda.getAnswerUrl()
          && this.getStatus() == qanda.getStatus()) {
        return true;
      }
    }

    return false;
  }
}
