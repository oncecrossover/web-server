package com.gibbon.peeq.db.model;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gibbon.peeq.util.QuandaUtil;

public class Quanda {
  private static final double PERCENTAGE_TO_RESPONDER = 0.7;
  public enum QnaStatus {
    PENDING, ANSWERED, EXPIRED
  }

  public enum LiveStatus {
    FALSE(0, "FALSE"),
    TRUE(1, "TRUE");

    private final int code;
    private final String value;

    LiveStatus(final int code, final String value) {
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
  private String asker;
  private String question;
  private String responder;
  private Integer rate;
  private String answerUrl;
  private String answerCoverUrl;
  private byte[] answerMedia;
  private byte[] answerCover;
  private int duration;
  private String status;
  private String active;
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

  public void setDuration(int duration) {
    this.duration = duration;
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
          && isEqual(this.getActive(), that.getActive())) {
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
    if (quanda.getStatus() != null) {
      this.setStatus(quanda.getStatus());
    }
    if (quanda.getAnswerUrl() != null) {
      this.setAnswerUrl(quanda.getAnswerUrl());
    }
    if (quanda.getAnswerMedia() != null) {
      this.setAnswerMedia(quanda.getAnswerMedia());
    }
    if (quanda.getAnswerCoverUrl() != null) {
      this.setAnswerCoverUrl(quanda.getAnswerCoverUrl());
    }
    if (quanda.getAnswerCover() != null) {
      this.setAnswerCover(quanda.getAnswerCover());
    }
    if (quanda.getDuration() != 0) {
      this.setDuration(quanda.getDuration());
    }
    if (quanda.getStatus() != null) {
      this.setStatus(quanda.getStatus());
    }
    if (quanda.getActive() != null) {
      this.setActive(quanda.getActive());
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
