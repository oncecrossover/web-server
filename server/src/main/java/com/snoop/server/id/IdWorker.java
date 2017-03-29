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
package com.snoop.server.id;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkArgument;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.codahale.metrics.Counter;
import com.codahale.metrics.MetricRegistry;
import com.snoop.server.exceptions.InvalidSystemClock;
import com.snoop.server.exceptions.InvalidUserAgentError;

public class IdWorker {

    private static final Logger LOGGER = LoggerFactory
            .getLogger(IdWorker.class);
    private static final Pattern AGENT_PATTERN = Pattern
            .compile("([a-zA-Z][a-zA-Z0-9\\-]*)");

    public static final long TWEPOCH = 1288834974657L;

    private static final long WORKER_ID_BITS = 10L;
    private static final long DATACENTER_ID_BITS = 0L;
    private static final long MAX_WORKER_ID = -1L ^ (-1L << WORKER_ID_BITS);
    private static final long MAX_DATACENTER_ID = -1L
            ^ (-1L << DATACENTER_ID_BITS);
    private static final long SEQUENCE_BITS = 12L;

    private static final long WORKER_ID_SHIFT = SEQUENCE_BITS;
    private static final long DATACENTER_ID_SHIFT = SEQUENCE_BITS
            + WORKER_ID_BITS;
    private static final long TIMESTAMP_LEFT_SHIFT = SEQUENCE_BITS
            + WORKER_ID_BITS + DATACENTER_ID_BITS;
    private static final long SEQUENCE_MASK = -1L ^ (-1L << SEQUENCE_BITS);

    private final MetricRegistry registry;
    private final Counter idsCounter;
    private final Counter exceptionsCounter;
    private final Map<String, Counter> agentCounters = new ConcurrentHashMap<String, Counter>();
    private final int workerId;
    private final int datacenterId = 0;
    private final boolean validateUserAgent;

    private final AtomicLong lastTimestamp = new AtomicLong(-1L);
    private final AtomicLong sequence;

    public IdWorker(final int workerId) {
      this(workerId, 0L, true, new MetricRegistry());
    }

    /**
     * Constructor
     * 
     * @param workerId
     *            Worker ID
     * @param startSequence
     *            Starting sequence number
     */
    public IdWorker(final int workerId, final long startSequence) {
        this(workerId, startSequence, true, new MetricRegistry());
    }

    /**
     * Constructor
     * 
     * @param workerId
     *            Worker ID
     * @param validateUserAgent
     *            Whether to validate the User-Agent headers or not
     */
    public IdWorker(final int workerId,
            final boolean validateUserAgent) {
        this(workerId, 0L, validateUserAgent,
                new MetricRegistry());
    }

    /**
     * Constructor
     * 
     * @param workerId
     *            Worker ID
     * @param startSequence
     *            Starting sequence number
     * @param validateUserAgent
     *            Whether to validate the User-Agent headers or not
     */
    public IdWorker(final int workerId,
            final long startSequence, final boolean validateUserAgent) {
        this(workerId, startSequence, validateUserAgent,
                new MetricRegistry());
    }

    /**
     * Constructor
     * 
     * @param workerId
     *            Worker ID
     * @param startSequence
     *            Starting sequence number
     * @param validateUserAgent
     *            Whether to validate the User-Agent headers or not
     * @param registry
     *            Metric Registry
     */
    public IdWorker(final int workerId,
            final long startSequence, final boolean validateUserAgent,
            final MetricRegistry registry) {

        checkNotNull(workerId);
        checkArgument(workerId >= 0, String.format(
                "worker Id can't be greater than %d or less than 0",
                MAX_WORKER_ID));
        checkArgument(workerId <= MAX_WORKER_ID, String.format(
                "worker Id can't be greater than %d or less than 0",
                MAX_WORKER_ID));

        checkNotNull(datacenterId);
        checkArgument(datacenterId >= 0, String.format(
                "datacenter Id can't be greater than %d or less than 0",
                MAX_DATACENTER_ID));
        checkArgument(datacenterId <= MAX_DATACENTER_ID, String.format(
                "datacenter Id can't be greater than %d or less than 0",
                MAX_DATACENTER_ID));

        checkNotNull(startSequence);

        this.workerId = workerId;
        this.validateUserAgent = validateUserAgent;
        this.registry = registry;

        LOGGER.info(
                "worker starting. timestamp left shift {}, datacenter id bits {}, worker id bits {}, sequence bits {}, workerid {}",
                TIMESTAMP_LEFT_SHIFT, DATACENTER_ID_BITS, WORKER_ID_BITS,
                SEQUENCE_BITS, workerId);

        sequence = new AtomicLong(startSequence);

        exceptionsCounter = registry.counter(MetricRegistry.name(
                IdWorker.class, "exceptions"));
        idsCounter = registry.counter(MetricRegistry.name(IdWorker.class,
                "ids_generated"));
    }

    /**
     * Get the next ID for a given user-agent
     * 
     * @param agent
     *            User Agent
     * @return Generated ID
     * @throws InvalidUserAgentError
     *             When the user agent is invalid
     * @throws InvalidSystemClock
     *             When the system clock is moving backward
     */
    public long getId(final String agent) throws InvalidUserAgentError,
            InvalidSystemClock {
        if (!isValidUserAgent(agent)) {
            exceptionsCounter.inc();
            throw new InvalidUserAgentError();
        }

        final long id = nextId();
        genCounter(agent);

        return id;
    }

    /**
     * Return the worker ID
     * 
     * @return Worker ID
     */
    public int getWorkerId() {
        return this.workerId;
    }

    /**
     * Return the data center ID
     * 
     * @return Datacenter ID
     */
    public int getDatacenterId() {
        return this.datacenterId;
    }

    /**
     * Return the current system time in milliseconds.
     * 
     * @return Current system time in milliseconds
     */
    public long getTimestamp() {
        return System.currentTimeMillis();
    }

    /**
     * Return the current sequence position
     * 
     * @return Current sequence position
     */
    public long getSequence() {
        return sequence.get();
    }

    /**
     * Set the sequence to a given value
     * 
     * @param value
     *            New sequence value
     */
    public void setSequence(final long value) {
        this.sequence.set(value);
    }

    /**
     * Get the next ID
     * 
     * @return Next ID
     * @throws InvalidSystemClock
     *             When the clock is moving backward
     */
    public synchronized long nextId() throws InvalidSystemClock {
        long timestamp = timeGen();
        long curSequence = 0L;

        final long prevTimestamp = lastTimestamp.get();

        if (timestamp < prevTimestamp) {
            exceptionsCounter.inc();
            LOGGER.error(
                    "clock is moving backwards. Rejecting requests until {}",
                    prevTimestamp);
            throw new InvalidSystemClock(
                    String.format(
                            "Clock moved backwards. Refusing to generate id for %d milliseconds",
                            (prevTimestamp - timestamp)));
        }

        if (prevTimestamp == timestamp) {
            curSequence = sequence.incrementAndGet() & SEQUENCE_MASK;
            if (curSequence == 0) {
                timestamp = tilNextMillis(prevTimestamp);
            }
        } else {
            curSequence = 0L;
            sequence.set(0L);
        }

        lastTimestamp.set(timestamp);
        final long id = ((timestamp - TWEPOCH) << TIMESTAMP_LEFT_SHIFT)
                | (datacenterId << DATACENTER_ID_SHIFT)
                | (workerId << WORKER_ID_SHIFT) | curSequence;

        LOGGER.trace(
                "prevTimestamp = {}, timestamp = {}, sequence = {}, id = {}",
                prevTimestamp, timestamp, sequence, id);

        return id;
    }

    /**
     * Return the next time in milliseconds
     * 
     * @param lastTimestamp
     *            Last timestamp
     * @return Next timestamp in milliseconds
     */
    protected long tilNextMillis(final long lastTimestamp) {
        long timestamp = timeGen();
        while (timestamp <= lastTimestamp) {
            timestamp = timeGen();
        }
        return timestamp;
    }

    /**
     * Generate a new timestamp (currently in milliseconds)
     * 
     * @return current timestamp in milliseconds
     */
    protected long timeGen() {
        return System.currentTimeMillis();
    }

    /**
     * Check whether the user agent is valid
     * 
     * @param agent
     *            User-Agent
     * @return True if the user agent is valid
     */
    public boolean isValidUserAgent(final String agent) {
        if (!validateUserAgent) {
            return true;
        }
        final Matcher matcher = AGENT_PATTERN.matcher(agent);
        return matcher.matches();
    }

    /**
     * Update the counters for a given user agent
     * 
     * @param agent
     *            User-Agent
     */
    protected void genCounter(final String agent) {
        idsCounter.inc();
        if (!agentCounters.containsKey(agent)) {
            agentCounters.put(agent, registry.counter(MetricRegistry.name(
                    IdWorker.class, "ids_generated_" + agent)));
        }
        agentCounters.get(agent).inc();
    }
}
