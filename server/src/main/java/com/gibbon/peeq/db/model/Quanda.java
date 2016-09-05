package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.util.Date;
import java.util.concurrent.TimeUnit;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.util.QuandaUtil;

public class Quanda {
  public enum QnaStatus {
    PENDING, ANSWERED, EXPIRED
  }

  private Long id;
  private String asker;
  private String question;
  private String responder;
  private Double rate;
  private String answerUrl;
  private byte[] answerAudio;
  private String status;
  private Date createdTime;
  private Date updatedTime;
  private Long snoops;
  private Long hoursToExpire;

  public Long getId() {
    return id;
  }

  public Quanda setId(final Long id) {
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

  public Long getSnoops() {
    return snoops;
  }

  public Quanda setSnoops(final Long snoops) {
    this.snoops = snoops;
    return this;
  }

  public Quanda setHoursToExpire(final Long hoursToExpire) {
    this.hoursToExpire = hoursToExpire;
    return this;
  }

  public Long getHoursToExpire() {
    return QuandaUtil.getHoursToExpire(createdTime);
  }

  @JsonIgnore
  public double getPayment4Answer() {
   return rate * 0.9;
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
          && isEqual(this.getAnswerUrl(), that.getAnswerUrl())
          && isEqual(this.getStatus(), that.getStatus())
          && isEqual(this.getRate(), that.getRate())) {
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

  public Quanda setAsIgnoreNull(final Quanda quanda) {
    if (quanda == null) {
      return this;
    }
    this.setId(quanda.getId());
    if (quanda.getAsker() != null) {
      this.setAsker(quanda.getAsker());
    }
    if (quanda.getQuestion() != null) {
      this.setQuestion(quanda.getQuestion());
    }
    if (quanda.getResponder() != null) {
      this.setResponder(quanda.getResponder());
    }
    if (quanda.getAnswerUrl() != null) {
      this.setAnswerUrl(quanda.getAnswerUrl());
    }
    if (quanda.getAnswerAudio() != null) {
      this.setAnswerAudio(quanda.getAnswerAudio());
    }
    if (quanda.getStatus() != null) {
      this.setStatus(quanda.getStatus());
    }
    if (quanda.getRate() != null) {
      this.setRate(quanda.getRate());
    }
    if (quanda.getCreatedTime() != null) {
      this.setCreatedTime(quanda.getCreatedTime());
    }
    if (quanda.getUpdatedTime() != null) {
      this.setUpdatedTime(quanda.getUpdatedTime());
    }
    return this;
  }
}
