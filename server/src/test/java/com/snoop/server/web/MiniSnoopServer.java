package com.snoop.server.web;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Supplier;
import com.snoop.server.test.GenericTestUtils;

public class MiniSnoopServer {
  private static final Logger LOG = LoggerFactory
      .getLogger(MiniSnoopServer.class);

  public static class Builder {
    public Builder() {
      sslEnabled = System.getProperty("http.snoop.ssl") != null;
      port = Integer
          .parseInt(System.getProperty("http.snoop.server.port", "0"));
    }

    private boolean sslEnabled;
    private int port = 0;

    public Builder sslEnabled(final boolean sslEnabled) {
      this.sslEnabled = sslEnabled;
      return this;
    }

    public Builder port(final int port) {
      this.port = port;
      return this;
    }

    public MiniSnoopServer build() {
      return new MiniSnoopServer(this);
    }
  }

  private HttpSnoopServer httpSnoopServerDaemon = null;

  private MiniSnoopServer(final Builder builder) {
    final HttpSnoopServer httpSnoopServer = new HttpSnoopServer(
        builder.sslEnabled, builder.port, false);

    httpSnoopServerDaemon = ((HttpSnoopServer) httpSnoopServer
        .runServerAsDaemon().getRunnable());
  }

  public int getPort() {
    return httpSnoopServerDaemon.getPort();
  }

  public String getHostName() {
    return httpSnoopServerDaemon.getHostName();
  }

  public String getHostString() {
    return httpSnoopServerDaemon.getHostString();
  }

  public boolean getSslEnabled() {
    return httpSnoopServerDaemon.sslEnabled();
  }

  public void waitActive() throws IOException {
    try {
      GenericTestUtils.waitFor(new Supplier<Boolean>() {
        @Override
        public Boolean get() {
          LOG.info("mini server channel active ? "
              + httpSnoopServerDaemon.getChannelActive());
          return httpSnoopServerDaemon.getChannelActive();
        }
      }, 100, 60000);
    } catch (TimeoutException | InterruptedException e) {
      throw new IOException(e);
    }
  }

  public void shutDown() throws IOException {
    httpSnoopServerDaemon.shutDown();
    try {
      GenericTestUtils.waitFor(new Supplier<Boolean>() {
        @Override
        public Boolean get() {
          LOG.info("mini server channel closed ? "
              + httpSnoopServerDaemon.getChannelClosed());
          return httpSnoopServerDaemon.getChannelClosed();
        }
      }, 100, 60000);
    } catch (TimeoutException | InterruptedException e) {
      throw new IOException(e);
    }
  }
}
