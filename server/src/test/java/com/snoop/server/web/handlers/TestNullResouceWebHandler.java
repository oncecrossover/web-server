package com.snoop.server.web.handlers;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.snoop.server.web.MiniSnoopClient;
import com.snoop.server.web.MiniSnoopServer;
import com.snoop.server.web.MiniSnoopClient.HttpType;
import static org.hamcrest.CoreMatchers.containsString;
import static org.junit.Assert.assertThat;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.util.CharsetUtil;

public class TestNullResouceWebHandler {
  private MiniSnoopServer server;
  private static final Logger LOG = LoggerFactory
      .getLogger(TestNotFoundResourceWebHandler.class);

  private MiniSnoopClient.Builder builder;

  @Before
  public void setup() throws IOException {
    server = new MiniSnoopServer.Builder().build();
    server.waitActive();
    builder = new MiniSnoopClient.Builder()
        .sslEnabled(server.getSslEnabled())
        .host(server.getHostString())
        .port(server.getPort());
  }

  @After
  public void tearDown() throws IOException {
    if (server != null) {
      server.shutDown();
    }
  }

  @Test(timeout = 30000)
  public void testNullResouce() throws Exception {
    /* test GET */
    try (MiniSnoopClient client = builder.build()) {
      client.sendRequest(HttpType.GET, "");
      client.waitForHttpResponse();
      client.waitForHttpContent();
      LOG.info("response status: " + client.getHttpResponse().status());
      assertEquals(HttpResponseStatus.OK, client.getHttpResponse().status());
      assertThat(client.getHttpContent().content().toString(CharsetUtil.UTF_8),
          containsString("No resource specified."));
    }

    /* test PUT */
    try (MiniSnoopClient client = builder.build()) {
      client.sendRequest(HttpType.PUT, "");
      client.waitForHttpResponse();
      client.waitForHttpContent();
      LOG.info("response status: " + client.getHttpResponse().status());
      assertEquals(HttpResponseStatus.NO_CONTENT,
          client.getHttpResponse().status());
    }

    /* test POST */
    try (MiniSnoopClient client = builder.build()) {
      client.sendRequest(HttpType.POST, "");
      client.waitForHttpResponse();
      client.waitForHttpContent();
      LOG.info("response status: " + client.getHttpResponse().status());
      assertEquals(HttpResponseStatus.CREATED,
          client.getHttpResponse().status());
      assertThat(client.getHttpContent().content().toString(CharsetUtil.UTF_8),
          containsString("No resource specified."));
    }

    /* test DELETE */
    try (MiniSnoopClient client = builder.build()) {
      client.sendRequest(HttpType.DELETE, "");
      client.waitForHttpResponse();
      client.waitForHttpContent();
      LOG.info("response status: " + client.getHttpResponse().status());
      assertEquals(HttpResponseStatus.NO_CONTENT,
          client.getHttpResponse().status());
    }
  }
}
