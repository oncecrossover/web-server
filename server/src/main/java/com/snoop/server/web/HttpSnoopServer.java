/*
 * Copyright 2012 The Netty Project
 *
 * The Netty Project licenses this file to you under the Apache License,
 * version 2.0 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at:
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
package com.snoop.server.web;

import java.net.InetSocketAddress;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.net.ssl.SSLException;

import org.apache.hadoop.util.Daemon;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import io.netty.handler.ssl.ClientAuth;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;

/**
 * An HTTP server that sends back the response of the received HTTP request in a
 * plain text or encrypted form.
 */
public final class HttpSnoopServer implements Runnable {

  private static final Logger LOG = LoggerFactory
      .getLogger(HttpSnoopServer.class);
  public static final boolean LIVE = System
      .getProperty("http.snoop.server.live") != null;

  public Daemon runServerAsDaemon() {
    final ThreadGroup threadGroup = new ThreadGroup("Http snoop server");
    final Daemon server = new Daemon(threadGroup,
        new HttpSnoopServer(sslEnabled, port, isliveMode));
    LOG.info("HttpSnoopServer daemon initialized");
    server.start();
    return server;
  }

  private boolean sslEnabled = false;
  private int port;
  private boolean isliveMode = false;
  private InetSocketAddress localAddr;
  private AtomicBoolean channelActive = new AtomicBoolean(false);
  private AtomicBoolean channelClosed = new AtomicBoolean(false);
  private EventLoopGroup bossGroup;
  private EventLoopGroup workerGroup;

  public HttpSnoopServer(final boolean sslEnabled, final int port,
      boolean isLiveMode) {
    this.sslEnabled = sslEnabled;
    this.port = port;
    this.isliveMode = isLiveMode;
  }

  public boolean getChannelActive() {
    return channelActive.get();
  }

  public boolean getChannelClosed() {
    return channelClosed.get();
  }

  public boolean sslEnabled() {
    return sslEnabled;
  }

  public int getPort() {
    return localAddr.getPort();
  }

  public String getHostName() {
    return localAddr.getHostName();
  }

  public String getHostString() {
    return localAddr.getHostString();
  }

  public static void main(String[] args) throws Exception {
    final boolean sslEnabled = System.getProperty("http.snoop.ssl") != null;
    final int port = Integer.parseInt(System
        .getProperty("http.snoop.server.port", sslEnabled ? "8443" : "8080"));

    final HttpSnoopServer server = new HttpSnoopServer(sslEnabled, port,
        LIVE);
    try {
      server.start();
    } finally {
      server.shutDown();
    }
  }

  private static SslContext setupSSL(final boolean sslEnabled)
      throws SSLException {
    final SslContext sslCtx;
    if (sslEnabled) {
      sslCtx = SslContextBuilder
          .forServer(SecureSnoopSslContextFactory.getServerKeyManagerFactory())
          .trustManager(
              SecureSnoopSslContextFactory.getServerTrustManagerFactory())
          .clientAuth(ClientAuth.REQUIRE)
          .build();
    } else {
      sslCtx = null;
    }
    return sslCtx;
  }

  private void start() throws SSLException, InterruptedException {
    LOG.info(String.format("SNOOP SERVER OPTIONS: SSL:%s, LIVE:%s", sslEnabled, LIVE));
    LOG.info("starting HttpSnoopServer daemon");

    // Configure SSL.
    final SslContext sslCtx = setupSSL(sslEnabled);

    // Configure the server.
    bossGroup = new NioEventLoopGroup(1);
    workerGroup = new NioEventLoopGroup();

    try {
      ServerBootstrap b = new ServerBootstrap();
      b.group(bossGroup, workerGroup)
          .channel(NioServerSocketChannel.class)
          .childHandler(new HttpSnoopServerInitializer(sslCtx));
      if (!LIVE) {
        b.handler(new LoggingHandler(LogLevel.INFO));
      }

      /* wait for channel being active */
      Channel ch = b.bind(port).sync().addListener(new ChannelFutureListener() {
        @Override
        public void operationComplete(ChannelFuture future) throws Exception {
          if (future.isSuccess()) {
            channelActive.set(true);
            LOG.info("netty server channel active ? " + channelActive);
          } else {
            channelActive.set(false);
            throw new Exception("failed to activate netty server channel.", future.cause());
          }
        }
      }).channel();
      localAddr = (InetSocketAddress) ch.localAddress();

      LOG.info("Open your web browser and navigate to "
          + (sslEnabled ? "https" : "http") + "://127.0.0.1:" + getPort());

      /* wait for channel being closed */
      ch.closeFuture().sync().addListener(new ChannelFutureListener() {
        @Override
        public void operationComplete(ChannelFuture future) throws Exception {
          if (future.isSuccess()) {
            channelClosed.set(true);
            LOG.info("netty server channel closed ? " + channelClosed);
          } else {
            channelClosed.set(false);
            throw new Exception("failed to close netty server channel.", future.cause());
          }
        }
      });
    } finally {
      workerGroup.shutdownGracefully();
      bossGroup.shutdownGracefully();
    }
  }

  public void shutDown() {
    if (workerGroup != null) {
      workerGroup.shutdownGracefully();
    }
    if (bossGroup != null) {
      bossGroup.shutdownGracefully();
    }
  }

  @Override
  public void run() {
    try {
      start();
    } catch (SSLException | InterruptedException e) {
      throw new RuntimeException(e);
    }
  }
}
