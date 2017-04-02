package com.snoop.server.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Snoop {
  private Long id;
  private Long uid;
  private Long quandaId;
  private Date createdTime;
  private String question;
  private String status;
  private Integer rate;
  private String answerUrl;
  private String answerCoverUrl;
  private byte[] answerCover;
  private int duration;
  private String responderName;
  private String responderTitle;
  private String responderAvatarUrl;
  private byte[] responderAvatarImage;
  private String askerName;
  private String askerAvatarUrl;
  private byte[] askerAvatarImage;

  public Long getId() {
    return id;
  }

  public Snoop setId(final Long id) {
    this.id = id;
    return this;
  }

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

  public Date getCreatedTime() {
    return createdTime;
  }

  public Snoop setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public String getQuestion() {
    return question;
  }

  public Snoop setQuestion(final String question) {
    this.question = question;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Snoop setStatus(final String status) {
    this.status = status;
    return this;
  }

  public Integer getRate() {
    return rate;
  }

  public Snoop setRate(final Integer rate) {
    this.rate = rate;
    return this;
  }

  public String getAnswerUrl() {
    return answerUrl;
  }

  public Snoop setAnswerUrl(final String answerUrl) {
    this.answerUrl = answerUrl;
    return this;
  }

  public String getAnswerCoverUrl() {
    return answerCoverUrl;
  }

  public Snoop setAnswerCoverUrl(final String answerCoverUrl) {
    this.answerCoverUrl = answerCoverUrl;
    return this;
  }

  public byte[] getAnswerCover() {
    return answerCover;
  }

  public Snoop setAnswerCover(final byte[] answerCover) {
    this.answerCover = answerCover;
    return this;
  }

  public int getDuration() {
    return duration;
  }

  public void setDuration(int duration) {
    this.duration = duration;
  }

  public String getResponderName() {
    return responderName;
  }

  public Snoop setResponderName(final String responderName) {
    this.responderName = responderName;
    return this;
  }

  public String getResponderTitle() {
    return responderTitle;
  }

  public Snoop setResponderTitle(final String responderTitle) {
    this.responderTitle = responderTitle;
    return this;
  }

  public String getResponderAvatarUrl() {
    return responderAvatarUrl;
  }

  public Snoop setResponderAvatarUrl(final String responderAvatarUrl) {
    this.responderAvatarUrl = responderAvatarUrl;
    return this;
  }

  public byte[] getResponderAvatarImage() {
    return responderAvatarImage;
  }

  public Snoop setResponderAvatarImage(final byte[] responderAvatarImage) {
    this.responderAvatarImage = responderAvatarImage;
    return this;
  }
  public String getAskerName() {
    return askerName;
  }

  public void setAskerName(String askerName) {
    this.askerName = askerName;
  }

  public String getAskerAvatarUrl() {
    return askerAvatarUrl;
  }

  public void setAskerAvatarUrl(String askerAvatarUrl) {
    this.askerAvatarUrl = askerAvatarUrl;
  }

  public byte[] getAskerAvatarImage() {
    return askerAvatarImage;
  }

  public void setAskerAvatarImage(byte[] askerAvatarImage) {
    this.askerAvatarImage = askerAvatarImage;
  }

  public static Snoop newSnoop(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    Snoop snoop = mapper.readValue(json, Snoop.class);
    return snoop;
  }

  @Override
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  private String toJsonStr() throws JsonProcessingException {
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
      Snoop that = (Snoop) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getUid(), that.getUid())
          && isEqual(this.getQuandaId(), that.getQuandaId())) {
        return true;
      }
    }

    return false;
  }

  private boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public Snoop setAsIgnoreNull(final Snoop that) {
    if (that == null) {
      return this;
    }

    if (that.getId() != null) {
      this.setId(that.getId());
    }
    if (that.getUid() != null) {
      this.setUid(that.getUid());
    }
    this.setQuandaId(that.getQuandaId());
    this.setCreatedTime(that.getCreatedTime());
    return this;
  }
}
