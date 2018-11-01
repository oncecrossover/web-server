package com.wallchain.server.db.model;

import com.fasterxml.jackson.core.JsonProcessingException;

public interface Model {
  boolean isEqual(Object a, Object b);

  String toJsonStr() throws JsonProcessingException;

  byte[] toJsonByteArray() throws JsonProcessingException;
}
