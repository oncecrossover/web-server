package com.gibbon.peeq.db.model;

import java.io.IOException;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public abstract class ModelBase implements Model {
  protected static final int PRIME = 16777619;

  @Override
  public boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public static <T extends ModelBase> T newInstance(
      final byte[] json,
      final Class<T> clazz)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    T result = mapper.readValue(json, clazz);
    return result;
  }

  @Override
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
  }

  @Override
  public String toJsonStr() throws JsonProcessingException {
    final ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this);
  }

  @Override
  public byte[] toJsonByteArray() throws JsonProcessingException {
    final ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsBytes(this);
  }

  public abstract <T extends ModelBase> T setAsIgnoreNull(final T obj);
}
