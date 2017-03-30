package com.snoop.server.model;

import java.util.Date;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.snoop.server.util.QuandaUtil;

public class Question {

  private Long id;
  private String question;
  private Integer rate;
  private String status;
  private Date createdTime;
  private Date updatedTime;
  private String answerUrl;
  private String answerCoverUrl;
  private byte[]  answerCover;
  private int duration;
  private Long hoursToExpire;
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

  public Question setId(final Long id) {
    this.id = id;
    return this;
  }

  public String getQuestion() {
    return question;
  }

  public Question setQuestion(final String question) {
    this.question = question;
    return this;
  }

  public Integer getRate() {
    return rate;
  }

  public Question setRate(final Integer rate) {
    this.rate = rate;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Question setStatus(final String status) {
    this.status = status;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Question setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public Question setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public String getAnswerUrl() {
    return answerUrl;
  }

  public Question setAnswerUrl(final String answerUrl) {
    this.answerUrl = answerUrl;
    return this;
  }

  public String getAnswerCoverUrl() {
    return answerCoverUrl;
  }

  public Question setAnswerCoverUrl(final String answerCoverUrl) {
    this.answerCoverUrl = answerCoverUrl;
    return this;
  }

  public byte[] getAnswerCover() {
    return answerCover;
  }

  public Question setAnswerCover(final byte[] answerCover) {
    this.answerCover = answerCover;
    return this;
  }

  public int getDuration() {
    return duration;
  }

  public void setDuration(int duration) {
    this.duration = duration;
  }


  public Long getHoursToExpire() {
    return QuandaUtil.getHoursToExpire(createdTime);
  }

  public Question setHoursToExpire(final Long hoursToExpire) {
    this.hoursToExpire = hoursToExpire;
    return this;
  }

  public String getResponderName() {
    return responderName;
  }

  public Question setResponderName(final String responderName) {
    this.responderName = responderName;
    return this;
  }

  public String getResponderTitle() {
    return responderTitle;
  }

  public Question setResponderTitle(final String responderTitle) {
    this.responderTitle = responderTitle;
    return this;
  }

  public String getResponderAvatarUrl() {
    return responderAvatarUrl;
  }

  public Question setResponderAvatarUrl(final String responderAvatarUrl) {
    this.responderAvatarUrl = responderAvatarUrl;
    return this;
  }

  public byte[] getResponderAvatarImage() {
    return responderAvatarImage;
  }

  public Question setResponderAvatarImage(final byte[] responderAvatarImage) {
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