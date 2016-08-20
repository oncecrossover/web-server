package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Quanda {
  public enum QnaStatus {
    PENDING, ANSWERED, EXPIRED
  }

  public enum ClearedStatus {
    TRUE(1, "TRUE"), FALSE(0, "FALSE");

    private final int code;
    private final String value;

    ClearedStatus(final int code, final String value) {
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

  private long id;
  private String asker;
  private String question;
  private String responder;
  private Double rate;
  private String answerUrl;
  private byte[] answerAudio;
  private String status;
  private String cleared;
  private Date createdTime;
  private Date updatedTime;
  private long snoops;

  public long getId() {
    return id;
  }

  public Quanda setId(final long id) {
    this.id = id;
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

  public Double getRate() {
    return rate;
  }

  public Quanda setRate(final Double rate) {
    this.rate = rate;
    return this;
  }

  public String getAnswerUrl() {
    return this.answerUrl;
  }

  public Quanda setAnswerUrl(final String answerUrl) {
    this.answerUrl = answerUrl;
    return this;
  }

  public byte[] getAnswerAudio() {
    return answerAudio;
  }

  public Quanda setAnswerAudio(final byte[] answerAudio) {
    this.answerAudio = answerAudio;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Quanda setStatus(final String status) {
    this.status = status;
    return this;
  }

  public String getCleared() {
    return cleared;
  }

  public Quanda setCleared(final String cleared) {
    this.cleared = cleared;
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

  public long getSnoops() {
    return snoops;
  }

  public Quanda setSnoops(final long snoops) {
    this.snoops = snoops;
    return this;
  }

  @Override
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  public String toJsonStr() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }

  public byte[] toJsonByteArray() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsBytes(this);
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
      Quanda that = (Quanda) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getAsker(), that.getAsker())
          && isEqual(this.getQuestion(), that.getQuestion())
          && isEqual(this.getResponder(), that.getResponder())
          && isEqual(this.getRate(), that.getRate())
          && isEqual(this.getAnswerUrl(), that.getAnswerUrl())
          && isEqual(this.getStatus(), that.getStatus())
          && isEqual(this.getCleared(), that.getCleared())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public static Quanda newQuanda(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    Quanda quanda = mapper.readValue(json, Quanda.class);
    return quanda;
  }

  public Quanda setAsIgnoreNull(final Quanda that) {
    if (that == null) {
      return this;
    }
    this.setId(that.getId());
    if (that.getAsker() != null) {
      this.setAsker(that.getAsker());
    }
    if (that.getQuestion() != null) {
      this.setQuestion(that.getQuestion());
    }
    if (that.getResponder() != null) {
      this.setResponder(that.getResponder());
    }
    if (that.getRate() != null) {
      this.setRate(that.getRate());
    }
    if (that.getAnswerUrl() != null) {
      this.setAnswerUrl(that.getAnswerUrl());
    }
    if (that.getAnswerAudio() != null) {
      this.setAnswerAudio(that.getAnswerAudio());
    }
    if (that.getStatus() != null) {
      this.setStatus(that.getStatus());
    }
    if (that.getCleared() != null) {
      this.setCleared(that.getCleared());
    }
    if (that.getCreatedTime() != null) {
      this.setCreatedTime(that.getCreatedTime());
    }
    if (that.getUpdatedTime() != null) {
      this.setUpdatedTime(that.getUpdatedTime());
    }
    return this;
  }
}
