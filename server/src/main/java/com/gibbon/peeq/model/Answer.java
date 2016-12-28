package com.gibbon.peeq.model;

import java.util.Date;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.util.QuandaUtil;

public class Answer {
  private Long id;
  private String question;
  private Double rate;
  private String status;
  private Date createdTime;
  private String answerCoverUrl;
  private byte[]  answerCover;
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

  public Answer setId(final Long id) {
    this.id = id;
    return this;
  }

  public String getQuestion() {
    return question;
  }

  public Answer setQuestion(final String question) {
    this.question = question;
    return this;
  }

  public Double getRate() {
    return rate;
  }

  public Answer setRate(final Double rate) {
    this.rate = rate;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Answer setStatus(final String status) {
    this.status = status;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Answer setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public String getAnswerCoverUrl() {
    return answerCoverUrl;
  }

  public Answer setAnswerCoverUrl(final String answerCoverUrl) {
    this.answerCoverUrl = answerCoverUrl;
    return this;
  }

  public byte[] getAnswerCover() {
    return answerCover;
  }

  public Answer setAnswerCover(final byte[] answerCover) {
    this.answerCover = answerCover;
    return this;
  }

  public Long getHoursToExpire() {
    return QuandaUtil.getHoursToExpire(createdTime);
  }
  public String getResponderName() {
    return responderName;
  }

  public Answer setResponderName(final String responderName) {
    this.responderName = responderName;
    return this;
  }

  public String getResponderTitle() {
    return responderTitle;
  }

  public Answer setResponderTitle(final String responderTitle) {
    this.responderTitle = responderTitle;
    return this;
  }

  public String getResponderAvatarUrl() {
    return responderAvatarUrl;
  }

  public Answer setResponderAvatarUrl(final String responderAvatarUrl) {
    this.responderAvatarUrl = responderAvatarUrl;
    return this;
  }

  public byte[] getResponderAvatarImage() {
    return responderAvatarImage;
  }

  public Answer setResponderAvatarImage(final byte[] responderAvatarImage) {
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
}
