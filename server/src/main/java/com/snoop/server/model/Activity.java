package com.snoop.server.model;

import java.util.Date;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.snoop.server.db.model.Model;
import com.snoop.server.db.model.ModelBase;
import com.snoop.server.db.model.Quanda;

public class Activity extends ModelBase implements Model {

  private Long id;
  private String question;
  private String status;
  private Integer rate;
  private Date createdTime;
  private String answerUrl;
  private String answerCoverUrl;
  private byte[]  answerCover;
  private int duration;
  private String isAskerAnonymous;
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

  public Activity setId(final Long id) {
    this.id = id;
    return this;
  }

  public String getQuestion() {
    return question;
  }

  public Activity setQuestion(final String question) {
    this.question = question;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Activity setStatus(final String status) {
    this.status = status;
    return this;
  }

  public Integer getRate() {
    return rate;
  }

  public Activity setRate(final Integer rate) {
    this.rate = rate;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public Activity setCreatedTime(final Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public String getAnswerUrl() {
    return answerUrl;
  }

  public Activity setAnswerUrl(final String answerUrl) {
    this.answerUrl = answerUrl;
    return this;
  }

  public String getAnswerCoverUrl() {
    return answerCoverUrl;
  }

  public Activity setAnswerCoverUrl(final String answerCoverUrl) {
    this.answerCoverUrl = answerCoverUrl;
    return this;
  }

  public byte[] getAnswerCover() {
    return answerCover;
  }

  public Activity setAnswerCover(final byte[] answerCover) {
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

  public Activity setIsAskerAnonymous(final String isAskerAnonymous) {
    this.isAskerAnonymous = isAskerAnonymous;
    return this;
  }

  public String getResponderName() {
    return responderName;
  }

  public Activity setResponderName(final String responderName) {
    this.responderName = responderName;
    return this;
  }

  public String getResponderTitle() {
    return responderTitle;
  }

  public Activity setResponderTitle(final String responderTitle) {
    this.responderTitle = responderTitle;
    return this;
  }

  public String getResponderAvatarUrl() {
    return responderAvatarUrl;
  }

  public Activity setResponderAvatarUrl(final String responderAvatarUrl) {
    this.responderAvatarUrl = responderAvatarUrl;
    return this;
  }

  public byte[] getResponderAvatarImage() {
    return responderAvatarImage;
  }

  public Activity setResponderAvatarImage(final byte[] responderAvatarImage) {
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

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof Activity) {
      Activity that = (Activity) obj;
      if (isEqual(this.getId(), that.getId())
          && isEqual(this.getQuestion(), that.getQuestion())
          && isEqual(this.getStatus(), that.getStatus())
          && isEqual(this.getRate(), that.getRate())
          && isEqual(this.getCreatedTime(), that.getCreatedTime())
          && isEqual(this.getAnswerUrl(), that.getAnswerUrl())
          && isEqual(this.getAnswerCoverUrl(), that.getAnswerCoverUrl())
          && isEqual(this.getDuration(), that.getDuration())
          && isEqual(this.getIsAskerAnonymous(), that.getIsAskerAnonymous())
          && isEqual(this.getResponderName(), that.getResponderName())
          && isEqual(this.getResponderTitle(), that.getResponderTitle())
          && isEqual(this.getResponderAvatarUrl(), that.getResponderAvatarUrl())
          && isEqual(this.getAskerName(), that.getAskerName())
          && isEqual(this.getAskerAvatarUrl(), that.getAskerAvatarUrl())) {
        return true;
      }
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((question == null) ? 0 : question.hashCode());
    result = PRIME * result + ((status == null) ? 0 : status.hashCode());
    result = PRIME * result + ((rate == null) ? 0 : rate.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result + ((answerUrl == null) ? 0 : answerUrl.hashCode());
    result = PRIME * result
        + ((answerCoverUrl == null) ? 0 : answerCoverUrl.hashCode());
    result = PRIME * result + duration;
    result = PRIME * result
        + ((isAskerAnonymous == null) ? 0 : isAskerAnonymous.hashCode());
    result = PRIME * result
        + ((responderName == null) ? 0 : responderName.hashCode());
    result = PRIME * result
        + ((responderTitle == null) ? 0 : responderTitle.hashCode());
    result = PRIME * result
        + ((responderAvatarUrl == null) ? 0 : responderAvatarUrl.hashCode());
    result = PRIME * result + ((askerName == null) ? 0 : askerName.hashCode());
    result = PRIME * result
        + ((askerAvatarUrl == null) ? 0 : askerAvatarUrl.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
  }
}

