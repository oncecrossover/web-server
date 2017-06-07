package com.snoop.server.db.model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.snoop.server.util.QuandaUtil;

public class Quanda extends ModelBase implements Model {
  private static final double PERCENTAGE_TO_RESPONDER = 0.7;
  public enum QnaStatus {
    PENDING(0, "PENDING"),
    ANSWERED(1, "ANSWERED"),
    EXPIRED(2, "EXPIRED");

    private final int code;
    private final String value;

    QnaStatus(final int code, final String value) {
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

  public enum ActiveStatus {
    FALSE(0, "FALSE"),
    TRUE(1, "TRUE");

    private final int code;
    private final String value;

    ActiveStatus(final int code, final String value) {
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

  public enum AnonymousStatus {
    FALSE(0, "FALSE"),
    TRUE(1, "TRUE");

    private final int code;
    private final String value;

    AnonymousStatus(final int code, final String value) {
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

  private Long id;
  private Long asker;
  private String question;
  private Long responder;
  private Integer rate;
  private String answerUrl;
  private String answerCoverUrl;
  private byte[] answerMedia;
  private byte[] answerCover;
  private int duration;
  private String status;
  private String active;
  private String isAskerAnonymous;
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

  public Long getAsker() {
    return asker;
  }

  public Quanda setAsker(final Long asker) {
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

  public Long getResponder() {
    return responder;
  }

  public Quanda setResponder(final Long responder) {
    this.responder = responder;
    return this;
  }

  public Integer getRate() {
    return rate;
  }

  public Quanda setRate(final Integer rate) {
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

  public String getAnswerCoverUrl() {
    return this.answerCoverUrl;
  }

  public Quanda setAnswerCoverUrl(final String answerCoverUrl) {
    this.answerCoverUrl = answerCoverUrl;
    return this;
  }

  public byte[] getAnswerMedia() {
    return answerMedia;
  }

  public Quanda setAnswerMedia(final byte[] answerMedia) {
    this.answerMedia = answerMedia;
    return this;
  }

  public Quanda setAnswerCover(final byte[] answerCover) {
    this.answerCover = answerCover;
    return this;
  }

  public byte[] getAnswerCover() {
    return answerCover;
  }

  public int getDuration() {
    return duration;
  }

  public Quanda setDuration(int duration) {
    this.duration = duration;
    return this;
  }

  public String getStatus() {
    return status;
  }

  public Quanda setStatus(final String status) {
    this.status = status;
    return this;
  }

  public String getActive() {
    return active;
  }

  public Quanda setActive(final String active) {
    this.active = active;
    return this;
  }

  public String getIsAskerAnonymous() {
    return this.isAskerAnonymous;
  }

  public Quanda setIsAskerAnonymous(final String isAskerAnonymous) {
    this.isAskerAnonymous = isAskerAnonymous;
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
  public double getPayment4Responder() {
    return new BigDecimal(rate * PERCENTAGE_TO_RESPONDER)
        .setScale(2, RoundingMode.FLOOR).doubleValue();
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
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((asker == null) ? 0 : asker.hashCode());
    result = PRIME * result + ((question == null) ? 0 : question.hashCode());
    result = PRIME * result + ((responder == null) ? 0 : responder.hashCode());
    result = PRIME * result + ((rate == null) ? 0 : rate.hashCode());
    result = PRIME * result + ((answerUrl == null) ? 0 : answerUrl.hashCode());
    result = PRIME * result
        + ((answerCoverUrl == null) ? 0 : answerCoverUrl.hashCode());
    result = PRIME * result + duration;
    result = PRIME * result + ((status == null) ? 0 : status.hashCode());
    result = PRIME * result + ((active == null) ? 0 : active.hashCode());
    result = PRIME * result
        + ((isAskerAnonymous == null) ? 0 : isAskerAnonymous.hashCode());
    return result;
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
          && isEqual(this.getAnswerCoverUrl(), that.getAnswerCoverUrl())
          && (this.getDuration() == that.getDuration())
          && isEqual(this.getStatus(), that.getStatus())
          && isEqual(this.getActive(), that.getActive())
          && isEqual(this.getIsAskerAnonymous(), that.getIsAskerAnonymous())) {
        return true;
      }
    }

    return false;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof Quanda) {
      final Quanda that = (Quanda)obj;
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
      if (that.getStatus() != null) {
        this.setStatus(that.getStatus());
      }
      if (that.getAnswerUrl() != null) {
        this.setAnswerUrl(that.getAnswerUrl());
      }
      if (that.getAnswerMedia() != null) {
        this.setAnswerMedia(that.getAnswerMedia());
      }
      if (that.getAnswerCoverUrl() != null) {
        this.setAnswerCoverUrl(that.getAnswerCoverUrl());
      }
      if (that.getAnswerCover() != null) {
        this.setAnswerCover(that.getAnswerCover());
      }
      if (that.getDuration() != 0) {
        this.setDuration(that.getDuration());
      }
      if (that.getStatus() != null) {
        this.setStatus(that.getStatus());
      }
      if (that.getActive() != null) {
        this.setActive(that.getActive());
      }
      if (that.getIsAskerAnonymous() != null) {
        this.setIsAskerAnonymous(that.getIsAskerAnonymous());
      }
    }
  }
}
