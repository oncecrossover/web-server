package com.snoop.server.model;

import static org.junit.Assert.*;

import java.io.IOException;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.snoop.server.db.model.ModelBase;
import com.snoop.server.db.model.TestProfile;

public class TestJsonLongStringSerde {
  private static final Logger LOG = LoggerFactory.getLogger(TestProfile.class);

  @Test
  public void testLongStringSerdeWithList() throws IOException {
    final IdValue idVal = new IdValue();
    idVal.setId(1L).setValue("1 long");
    final List<IdValue> values = Lists.newArrayList();
    values.add(new IdValue().setId(1L).setValue("1 long"));
    values.add(new IdValue().setId(2L).setValue("2 long"));
    values.add(new IdValue().setId(3L).setValue("3 long"));
    values.add(new IdValue().setId(4L).setValue("4 long"));

    final String expected = "[{\"id\":\"1\",\"value\":\"1 long\"},{\"id\":\"2\",\"value\":\"2 long\"},{\"id\":\"3\",\"value\":\"3 long\"},{\"id\":\"4\",\"value\":\"4 long\"}]";
    assertEquals(expected, listToJsonString(values));
  }

  <T> String listToJsonString(final List<T> list) {
    /* build json */
    final StrBuilder sb = new StrBuilder();
    sb.append("[");
    if (list != null) {
      sb.append(Joiner.on(",").skipNulls().join(list));
    }
    sb.append("]");
    return sb.toString();
  }

  @Test
  public void testLongStringSerde() throws IOException {
    final IdValue idVal = new IdValue();
    idVal.setId(Long.MAX_VALUE).setValue("hello, snooper");

    final String json = idVal.toJsonStr();
    assertNotNull(json);
    assertTrue(StringUtils.isNotEmpty(json));
    LOG.info("json: " + json);

    final IdValue idVal2 = IdValue.newInstance(json, IdValue.class);
    assertNotNull(idVal2);
    final String json2 = idVal2.toJsonStr();
    LOG.info("json2: " + json2);
    assertEquals(idVal, idVal2);
    assertEquals(json, json2);

    final String json3 = "{\"id\":\"9223372036854775807\",\"value\":\"hello, snooper\"}";
    final IdValue idVal3 = IdValue.newInstance(json3, IdValue.class);
    LOG.info("json3: " + json3);
    assertEquals(idVal, idVal3);
    assertEquals(json, json3);

    final String json4 = "{\"id\":9223372036854775807,\"value\":\"hello, snooper\"}";
    final IdValue idVal4 = IdValue.newInstance(json4, IdValue.class);
    LOG.info("json4: " + json4);
    assertEquals(idVal, idVal4);
    assertNotEquals(json, json4);
  }

  public static class IdValue extends ModelBase {
    private Long id;
    private String value;

    @JsonSerialize(using = ToStringSerializer.class)
    public Long getId() {
      return id;
    }

    public IdValue setId(final Long id) {
      this.id = id;
      return this;
    }

    public String getValue() {
      return value;
    }

    public IdValue setValue(final String value) {
      this.value = value;
      return this;
    }

    @Override
    public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      }

      if (obj instanceof IdValue) {
        final IdValue that = (IdValue) obj;
        if (isEqual(this.getId(), that.getId())
            && isEqual(this.getValue(), that.getValue())) {
          return true;
        }
      }

      return false;
    }

    @Override
    public int hashCode() {
      int result = 0;
      result = PRIME * result + ((id == null) ? 0 : id.hashCode());
      result = PRIME * result + ((value == null) ? 0 : value.hashCode());
      return result;
    }

    @Override
    public <T extends ModelBase> void setAsIgnoreNull(T obj) {
    }
  }
}
