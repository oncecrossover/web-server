package com.snoop.server.db.model;

public class EnumBase {
  private final int code;
  private final String value;

  EnumBase(final int code, final String value) {
    this.code = code;
    this.value = value;
  }

  public int code() {
    return code;
  }

  public String value() {
    return value;
  }

  @Override
  public String toString() {
    return value;
  }

  @Override
  public int hashCode() {
    return value.hashCode();
  }
}
