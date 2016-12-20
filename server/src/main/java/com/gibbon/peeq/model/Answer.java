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
  private String askerName;
  private String askerTitle;
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

  public String getAskerName() {
    return askerName;
  }

  public Answer setAskerName(final String askerName) {
    this.askerName = askerName;
    return this;
  }

  public String getAskerTitle() {
    return askerTitle;
  }

  public Answer setAskerTitle(final String askerTitle) {
    this.askerTitle = askerTitle;
    return this;
  }

  public String getAskerAvatarUrl() {
    return askerAvatarUrl;
  }

  public Answer setAskerAvatarUrl(final String askerAvatarUrl) {
    this.askerAvatarUrl = askerAvatarUrl;
    return this;
  }

  public byte[] getAskerAvatarImage() {
    return askerAvatarImage;
  }

  public Answer setAskerAvatarImage(final byte[] askerAvatarImage) {
    this.askerAvatarImage = askerAvatarImage;
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
}
