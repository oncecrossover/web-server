/*
 * Copyright 2010-2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.snoop.server.core;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.failBecauseExceptionWasNotThrown;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import java.util.List;
import java.util.Set;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.exceptions.InvalidSystemClock;
import com.gibbon.peeq.exceptions.InvalidUserAgentError;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.snoop.server.core.IdWorker;

public class IdWorkerTest {
    private static final long WORKER_MASK =     0x000000000001F000L;
    private static final long TIMESTAMP_MASK =  0xFFFFFFFFFFC00000L;

    class EasyTimeWorker extends IdWorker {
        public List<Long> queue = Lists.newArrayList();

        public EasyTimeWorker(final Integer workerId) {
            super(workerId);
        }

        public void addTimestamp(final Long timestamp) {
            queue.add(timestamp);
        }

        public Long timeMaker() {
            return queue.remove(0);
        }

        @Override
        protected long timeGen() {
            return timeMaker();
        }
    }

    class WakingIdWorker extends EasyTimeWorker {
        public int slept = 0;

        public WakingIdWorker(final Integer workerId) {
            super(workerId);
        }

        @Override
        protected long tilNextMillis(final long lastTimestamp) {
            slept += 1;
            return super.tilNextMillis(lastTimestamp);
        }
    }

    class StaticTimeWorker extends IdWorker {
        public long time = 1L;

        public StaticTimeWorker(final Integer workerId) {
            super(workerId);
        }

        @Override
        protected long timeGen() {
            return time + TWEPOCH;
        }
    }

    @Test
    @SuppressWarnings("null")
    public void testInvalidWorkerId() {
        try {
            final Integer workerId = null;
            new IdWorker(workerId);
            failBecauseExceptionWasNotThrown(NullPointerException.class);
        } catch (NullPointerException e) {
        }

        try {
            new IdWorker(-1);
            failBecauseExceptionWasNotThrown(IllegalArgumentException.class);
        } catch (IllegalArgumentException e) {
        }

        try {
            new IdWorker(1024);
            failBecauseExceptionWasNotThrown(IllegalArgumentException.class);
        } catch (IllegalArgumentException e) {
        }
    }

    @Test
    public void testGenerateId() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        final Long id = worker.nextId();
        assertThat(id).isGreaterThan(0L);
    }

    @Test
    public void testAccurateTimestamp() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        final Long time = System.currentTimeMillis();
        assertThat(worker.getTimestamp() - time).isLessThan(50L);
    }

    @Test
    public void testWorkerId() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        assertThat(worker.getWorkerId()).isEqualTo(1);
    }

    @Test
    public void testDatacenterId() throws Exception {
        final IdWorker worker = new IdWorker(1);
        assertThat(worker.getDatacenterId()).isEqualTo(0);
    }

    @Test
    public void testMaskWorkerId() throws Exception {
        final Integer workerId = 0x1F;
        final IdWorker worker = new IdWorker(workerId);
        for (int i = 0; i < 1000; i++) {
            Long id = worker.nextId();
            assertThat((id & WORKER_MASK) >> 12).isEqualTo(
                    Long.valueOf(workerId));
        }
    }

    @Test
    public void testMaskTimestamp() throws Exception {
        final EasyTimeWorker worker = new EasyTimeWorker(31);
        for (int i = 0; i < 100; i++) {
            Long timestamp = System.currentTimeMillis();
            worker.addTimestamp(timestamp);
            Long id = worker.nextId();
            assertThat((id & TIMESTAMP_MASK) >> 22).isEqualTo(
                    timestamp - IdWorker.TWEPOCH);
        }
    }

    @Test
    public void testRollOverSequenceId() throws Exception {
        final Integer workerId = 4;
        final Long startSequence = 0xFFFFFF - 20L;
        final Long endSequence = 0xFFFFFF + 20L;
        final IdWorker worker = new IdWorker(workerId,
                startSequence);

        for (Long i = startSequence; i < endSequence; i++) {
            Long id = worker.nextId();
            assertThat((id & WORKER_MASK) >> 12).isEqualTo(
                    Long.valueOf(workerId));
        }
    }

    @Test
    public void testIncreasingIds() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        Long lastId = 0L;
        for (int i = 0; i < 100; i++) {
            Long id = worker.nextId();
            assertThat(id).isGreaterThan(lastId);
            lastId = id;
        }
    }

    @Test
    public void testMillionIds() throws Exception {
        final IdWorker worker = new IdWorker(0, 3);
        final Long startTime = System.currentTimeMillis();
        for (int i = 0; i < 1000000; i++) {
            worker.nextId();
        }
        final Long endTime = System.currentTimeMillis();
        System.out.println(String.format(
                "generated 1000000 ids in %d ms, or %,.0f ids/second",
                (endTime - startTime), 1000000000.0 / (endTime - startTime)));
    }

    @Test
    public void testSleep() throws Exception {
        final WakingIdWorker worker = new WakingIdWorker(1);
        worker.addTimestamp(2L);
        worker.addTimestamp(2L);
        worker.addTimestamp(3L);

        worker.setSequence(4095L);
        worker.nextId();
        worker.setSequence(4095L);
        worker.nextId();

        assertThat(worker.slept).isEqualTo(1);
    }

    @Test
    public void testGenerateUniqueIds() throws Exception {
        final IdWorker worker = new IdWorker(31, 3);
        final Set<Long> ids = Sets.newHashSet();
        final int count = 2000000;
        for (int i = 0; i < count; i++) {
            Long id = worker.nextId();
            if (ids.contains(id)) {
                System.out.println(Long.toBinaryString(id));
            } else {
                ids.add(id);
            }
        }
        assertThat(ids.size()).isEqualTo(count);
    }

    private static final Logger LOG = LoggerFactory
        .getLogger(IdWorkerTest.class);

    @Test
    public void testGenerateIdPrintout() throws Exception {
      final IdWorker worker = new IdWorker(0, 0);
      for (int i = 0; i < 100; i++) {
      LOG.info("the id is: " + worker.nextId());
      }
    }

    @Test
    public void testGenerateIdsOver50Billion() throws Exception {
        final IdWorker worker = new IdWorker(0, 0);
        assertThat(worker.nextId()).isGreaterThan(50000000000L);
    }

    @Test
    public void testUniqueIdsBackwardsTime() throws Exception {
        final long sequenceMask = -1L ^ (-1L << 12);
        final StaticTimeWorker worker = new StaticTimeWorker(0);

        // first we generate 2 ids with the same time, so that we get the
        // sequqence to 1
        assertThat(worker.getSequence()).isEqualTo(0L);
        assertThat(worker.time).isEqualTo(1L);

        final Long id1 = worker.nextId();
        assertThat(id1 >> 22).isEqualTo(1L);
        assertThat(id1 & sequenceMask).isEqualTo(0L);

        assertThat(worker.getSequence()).isEqualTo(0L);
        assertThat(worker.time).isEqualTo(1L);

        final Long id2 = worker.nextId();
        assertThat(id2 >> 22).isEqualTo(1L);
        assertThat(id2 & sequenceMask).isEqualTo(1L);

        // then we set the time backwards
        worker.time = 0L;
        assertThat(worker.getSequence()).isEqualTo(1L);

        try {
            worker.nextId();
            failBecauseExceptionWasNotThrown(InvalidSystemClock.class);
        } catch (InvalidSystemClock ex) {
            assertThat(worker.getSequence()).isEqualTo(1L);
        }

        worker.time = 1L;
        final Long id3 = worker.nextId();
        assertThat(id3 >> 22).isEqualTo(1L);
        assertThat(id3 & sequenceMask).isEqualTo(2L);
    }

    @Test
    public void testValidUserAgent() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        assertTrue(worker.isValidUserAgent("infra-dm"));
    }

    @Test
    public void testInvalidUserAgent() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        assertFalse(worker.isValidUserAgent("1"));
        assertFalse(worker.isValidUserAgent("1asdf"));
    }

    @Test
    public void testGetIdInvalidUserAgent() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        try {
            worker.getId("1");
            failBecauseExceptionWasNotThrown(InvalidUserAgentError.class);
        } catch (InvalidUserAgentError e) {
        }
    }

    @Test
    public void testGetId() throws Exception {
        final IdWorker worker = new IdWorker(1, 1);
        final long id = worker.getId("infra-dm");
        assertThat(id).isGreaterThan(0L);
    }
}
