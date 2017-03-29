package com.snoop.server.id;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;

import org.junit.Test;

import com.google.common.collect.Sets;

public class TestUniqueIdGenerator {

  @Test
  public void testGenerateUniqueIds() throws Exception {
      final UniqueIdGenerator generator = new UniqueIdGenerator();
      final Set<Long> ids = Sets.newHashSet();
      final int count = 2000000;
      for (int i = 0; i < count; i++) {
          Long id = (Long) generator.generate(null, null);
          if (ids.contains(id)) {
              System.out.println(Long.toBinaryString(id));
          } else {
              ids.add(id);
          }
      }
      assertThat(ids.size()).isEqualTo(count);
  }
}
