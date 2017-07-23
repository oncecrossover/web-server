package com.snoop.server.model;

import java.util.Date;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;

public class Newsfeed {
  private Long id;
  private String question;
  private Integer rate;
  private Date updatedTime;
  private String answerUrl;
  private String answerCoverUrl;
  private byte[]  answerCover;
  private int duration;
  private String isAskerAnonymous;
  private String askerName;
  private String askerAvatarUrl;
  private Long responderId;
  private String responderName;
  private String responderTitle;
  private String responderAvatarUrl;
  private byte[] responderAvatarImage;
  private Long snoops;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public Newsfeed setId(final Long id) {
    this.id = id;
    return this;
  }

  public String getQuestion() {
    return question;
  }

  public Newsfeed setQuestion(final String question) {
    this.question = question;
    return this;
  }

  public Integer getRate() {
    return rate;
  }

  public Newsfeed setRate(final Integer rate) {
    this.rate = rate;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public Newsfeed setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public String getAnswerUrl() {
    return answerUrl;
  }

  public Newsfeed setAnswerUrl(final String answerUrl) {
    this.answerUrl = answerUrl;
    return this;
  }

  public String getAnswerCoverUrl() {
    return answerCoverUrl;
  }

  public Newsfeed setAnswerCoverUrl(final String answerCoverUrl) {
    this.answerCoverUrl = answerCoverUrl;
    return this;
  }

  public byte[] getAnswerCover() {
    return answerCover;
  }

  public Newsfeed setAnswerCover(final byte[] answerCover) {
    this.answerCover = answerCover;
    return this;
  }

  public int getDuration() {
    return duration;
  }

  public void setDuration(int duration) {
    this.duration = duration;
  }

  public String getIsAskerAnonymous() {
    return this.isAskerAnonymous;
  }

  public Newsfeed setIsAskerAnonymous(final String isAskerAnonymous) {
    this.isAskerAnonymous = isAskerAnonymous;
    return this;
  }

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getResponderId() {
    return responderId;
  }

  public Newsfeed setResponderId(final Long responderId) {
    this.responderId = responderId;
    return this;
  }

  public String getResponderName() {
    return responderName;
  }

  public Newsfeed setResponderName(final String responderName) {
    this.responderName = responderName;
    return this;
  }

  public String getResponderTitle() {
    return responderTitle;
  }

  public Newsfeed setResponderTitle(final String responderTitle) {
    this.responderTitle = responderTitle;
    return this;
  }

  public String getAskerName() {
    return askerName;
  }

  public Newsfeed setAskerName(final String askerName) {
    this.askerName = askerName;
    return this;
  }

  public String getAskerAvatarUrl() {
    return askerAvatarUrl;
  }

  public Newsfeed setAskerAvatarUrl(final String askerAvatarUrl) {
    this.askerAvatarUrl = askerAvatarUrl;
    return this;
  }

  public String getResponderAvatarUrl() {
    return responderAvatarUrl;
  }

  public Newsfeed setResponderAvatarUrl(final String responderAvatarUrl) {
    this.responderAvatarUrl = responderAvatarUrl;
    return this;
  }

  public byte[] getResponderAvatarImage() {
    return responderAvatarImage;
  }

  public Newsfeed setResponderAvatarImage(final byte[] responderAvatarImage) {
    this.responderAvatarImage = responderAvatarImage;
    return this;
  }

  public Long getSnoops() {
    return snoops;
  }

  public Newsfeed setSnoops(final Long snoops) {
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
}
