package com.wallchain.server.web.handlers;

import static org.junit.Assert.*;

import java.io.IOException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.wallchain.server.web.MiniSnoopClient;
import com.wallchain.server.web.MiniSnoopServer;

import io.netty.handler.codec.http.HttpResponseStatus;

public class TestNotFoundResourceWebHandler {
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
  public void testNotFoundResource() throws Exception {
    try (MiniSnoopClient client = builder.build()) {
      client.sendRequest("unknown_resource");
      client.waitForHttpResponse();
      LOG.info("response status: " + client.getHttpResponse().status());
      assertEquals(HttpResponseStatus.NOT_FOUND,
          client.getHttpResponse().status());
    }
  }
}
