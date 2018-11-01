package com.wallchain.server.model;

import java.util.HashMap;
import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class BulkData {

  private Map<String, byte[]> bytesMap = new HashMap<>();

  public BulkData add(final String uri, final byte[] data) {
    bytesMap.put(uri, data);
    return this;
  }

  public byte[] toJsonByteArray() throws JsonProcessingException {
    final ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsBytes(this.bytesMap);
  }

  public String toJsonStr() throws JsonProcessingException {
    final ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this.bytesMap);
  }

  @Override
  public String toString() {
    try {
      return toJsonStr();
    } catch (JsonProcessingException e) {
      return "";
    }
  }
}
