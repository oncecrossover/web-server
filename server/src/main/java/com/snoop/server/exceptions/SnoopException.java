package com.snoop.server.exceptions;

public class SnoopException extends Exception {
  private static final long serialVersionUID = -6834695620961183088L;

  public SnoopException(String message) {
    super(message);
  }

  public SnoopException(String message, Throwable cause) {
    super(message, cause);
  }

  public SnoopException(Throwable cause) {
    super(cause);
  }
}
