package com.gibbon.peeq.model;

import java.util.Date;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class Newsfeed {
  private Long quandaId;
  private String question;
  private Date updatedTime;
  private String responderId;
  private String responderName;
  private String responderTitle;
  private String responderAvatarUrl;
  private byte[] responderAvatarImage;
  private Long snoops;

  public Long getQuandaId() {
    return quandaId;
  }

  public Newsfeed setQuandaId(final Long quandaId) {
    this.quandaId = quandaId;
    return this;
  }

  public String getQuestion() {
    return question;
  }

  public Newsfeed setQuestion(final String question) {
    this.question = question;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public Newsfeed setUpdatedTime(final Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public String getResponderId() {
    return responderId;
  }

  public Newsfeed setResponderId(final String responderId) {
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