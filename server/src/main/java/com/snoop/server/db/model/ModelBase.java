package com.snoop.server.db.model;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.TypeFactory;

public abstract class ModelBase implements Model {
  protected static final int PRIME = 31;

  @Override
  public boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  public static <T> T newInstance(
      final byte[] json,
      final Class<T> clazz)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    T result = mapper.readValue(json, clazz);
    return result;
  }

  public static <T> T newInstance(
      final String json,
      final Class<T> clazz)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    T result = mapper.readValue(json, clazz);
    return result;
  }

  public static <T> List<T> newInstanceAsList(
      final byte[] json,
      final Class<T> clazz)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    TypeFactory tf = TypeFactory.defaultInstance();
    List<T> result = mapper.readValue(
        json,
        tf.constructCollectionType(ArrayList.class, clazz));
    return result;
  }

  public static <T> List<T> newInstanceAsList(
      final String json,
      final Class<T> clazz)
      throws JsonParseException, JsonMappingException, IOException {
    final ObjectMapper mapper = new ObjectMapper();
    TypeFactory tf = TypeFactory.defaultInstance();
    List<T> result = mapper.readValue(
        json,
        tf.constructCollectionType(ArrayList.class, clazz));
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

  public abstract <T extends ModelBase> void setAsIgnoreNull(final T obj);
}
