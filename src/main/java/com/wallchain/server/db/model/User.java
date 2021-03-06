package com.wallchain.server.db.model;

import java.io.IOException;
import java.util.Date;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import com.wallchain.server.db.model.Profile.TakeQuestionStatus;

public class User extends ModelBase {
  public enum SourceEnum {
    FACEBOOK(0, "FALSE"),
    TWITTER(1, "TRUE"),
    INSTAGRAM(2, "TRUE"),
    GMAIL(3, "TRUE"),
    EMAIL(4, "TRUE");

    private final int code;
    private final String value;

    SourceEnum(final int code, final String value) {
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
  private String uname;
  private String pwd;
  private String primaryEmail;
  private String source;
  private Date createdTime;
  private Date updatedTime;
  private String fullName;
  private Profile profile;
  private PcAccount pcAccount;

  @JsonSerialize(using=ToStringSerializer.class)
  public Long getId() {
    return id;
  }

  public User setId(Long id) {
    this.id = id;
    return this;
  }

  public String getUname() {
    return uname;
  }

  public User setUname(final String uname) {
    this.uname = uname;
    return this;
  }

  public String getFullName() {
    return fullName;
  }

  public User setFullName(final String fullName) {
    this.fullName = fullName;
    return this;
  }

  public String getPwd() {
    return pwd;
  }

  public User setPwd(String pwd) {
    this.pwd = pwd;
    return this;
  }

  public String getPrimaryEmail() {
    return primaryEmail;
  }

  public User setPrimaryEmail(final String primaryEmail) {
    this.primaryEmail = primaryEmail;
    return this;
  }

  public String getSource() {
    return source;
  }

  public User setSource(final String source) {
    this.source = source;
    return this;
  }

  public Date getCreatedTime() {
    return createdTime;
  }

  public User setCreatedTime(Date createdTime) {
    this.createdTime = createdTime;
    return this;
  }

  public Date getUpdatedTime() {
    return updatedTime;
  }

  public User setUpdatedTime(Date updatedTime) {
    this.updatedTime = updatedTime;
    return this;
  }

  public Profile getProfile() {
    return profile;
  }

  public User setProfile(final Profile profile) {
    this.profile = profile;
    return this;
  }

  public PcAccount getPcAccount() {
    return pcAccount;
  }

  public User setPcAccount(final PcAccount pcAccount) {
    this.pcAccount = pcAccount;
    return this;
  }

  /**
   * Instantiates a new User.
   * @param userJson Json byte array of User.
   * @return new instance of User.
   */
  public static User newInstance(final byte[] json)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    final User user = mapper.readValue(json, User.class);
    /* always make uname case insensitive */
    user.uname = user.uname != null ? user.uname.toLowerCase() : user.uname;

    if (user.getProfile() == null) {
      user.setProfile(new Profile());
      user.getProfile().setTakeQuestion(TakeQuestionStatus.NA.value());
    }
    user.getProfile().setUser(user);

    if (user.getPcAccount() == null) {
      user.setPcAccount(new PcAccount());
    }
    user.getPcAccount().setUser(user);
    return user;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }

    if (obj instanceof User) {
      final User that = (User) obj;
      return isEqual(this.getId(), that.getId())
          && isEqual(this.getUname(), that.getUname())
          && isEqual(this.getPwd(), that.getPwd())
          && isEqual(this.getPrimaryEmail(), that.getPrimaryEmail())
          && isEqual(this.getSource(), that.getSource())
          && isEqual(this.getCreatedTime(), that.getCreatedTime())
          && isEqual(this.getUpdatedTime(), that.getUpdatedTime())
          && isEqual(this.getFullName(), that.getFullName())
          && isEqual(this.getProfile(), that.getProfile())
          && isEqual(this.getPcAccount(), that.getPcAccount());
    }

    return false;
  }

  @Override
  public int hashCode() {
    int result = 0;
    result = PRIME * result + ((id == null) ? 0 : id.hashCode());
    result = PRIME * result + ((uname == null) ? 0 : uname.hashCode());
    result = PRIME * result + ((pwd == null) ? 0 : pwd.hashCode());
    result = PRIME * result + ((primaryEmail == null) ? 0 : primaryEmail.hashCode());
    result = PRIME * result + ((source == null) ? 0 : source.hashCode());
    result = PRIME * result
        + ((createdTime == null) ? 0 : createdTime.hashCode());
    result = PRIME * result
        + ((updatedTime == null) ? 0 : updatedTime.hashCode());
    result = PRIME * result + ((fullName == null) ? 0 : fullName.hashCode());
    result = PRIME * result + ((profile == null) ? 0 : profile.hashCode());
    result = PRIME * result + ((pcAccount == null) ? 0 : pcAccount.hashCode());
    return result;
  }

  @Override
  public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    if (obj instanceof User) {
      final User that = (User) obj;

      if (that.getId() != null) {
        this.setId(that.getId());
      }
      if (that.getUname() != null) {
        this.setUname(that.getUname());
      }
      if (that.getPwd() != null) {
        this.setPwd(that.getPwd());
      }
      if (that.getPrimaryEmail() != null) {
        this.setPrimaryEmail(that.getPrimaryEmail());
      }
      if (that.getSource() != null) {
        this.setSource(that.getSource());
      }
      if (that.getCreatedTime() != null) {
        this.setCreatedTime(that.getCreatedTime());
      }
      if (that.getUpdatedTime() != null) {
        this.setUpdatedTime(that.getUpdatedTime());
      }
      if (that.getProfile() != null && this.getProfile() != null) {
        this.getProfile().setAsIgnoreNull(that.getProfile());
      }
      if (that.getPcAccount() != null && this.getPcAccount() != null) {
        this.getPcAccount().setAsIgnoreNull(that.getPcAccount());
      }
      if (that.getFullName() != null && this.getProfile() != null) {
        this.getProfile().setFullName(that.getFullName());
      }
    }
  }
}