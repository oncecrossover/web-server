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

import javax.net.ssl.SSLException;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.Channel;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;

/**
 * An HTTP server that sends back the response of the received HTTP request in a
 * plain text or encrypted form.
 */
public final class HttpSnoopServer {

  static final boolean SSL =
      System.getProperty("http.snoop.ssl") != null;
  static final int PORT = Integer.parseInt(
      System.getProperty("http.snoop.server.port", SSL ? "8443" : "8080"));
  public static final boolean LIVE = System
      .getProperty("http.snoop.server.live") != null;

  public static void main(String[] args) throws Exception {
    start();
  }

  private static SslContext setupSSL(final boolean sslEnabled)
      throws SSLException {
    final SslContext sslCtx;
    if (sslEnabled) {
      sslCtx = SslContextBuilder
          .forServer(SecureSnoopSslContextFactory.getServerKeyManagerFactory())
          .trustManager(
              SecureSnoopSslContextFactory.getServerTrustManagerFactory())
          .build();
    } else {
      sslCtx = null;
    }
    return sslCtx;
  }

  static void start() throws SSLException, InterruptedException {
    // Configure SSL.
    final SslContext sslCtx = setupSSL(SSL);

    // Configure the server.
    EventLoopGroup bossGroup = new NioEventLoopGroup(1);
    EventLoopGroup workerGroup = new NioEventLoopGroup();
    try {
      ServerBootstrap b = new ServerBootstrap();
      b.group(bossGroup, workerGroup).channel(NioServerSocketChannel.class)
          .handler(new LoggingHandler(LogLevel.INFO))
          .childHandler(new HttpSnoopServerInitializer(sslCtx));

      Channel ch = b.bind(PORT).sync().channel();

      System.out.println(String.format("SNOOP OPTIONS: SSL:%s, LIVE:%s",
          SSL, LIVE));
      System.err.println("Open your web browser and navigate to "
          + (SSL ? "https" : "http") + "://127.0.0.1:" + PORT + '/');

      ch.closeFuture().sync();
    } finally {
      bossGroup.shutdownGracefully();
      workerGroup.shutdownGracefully();
    }
  }
}
