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
package com.gibbon.peeq.snoop;

import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.http.DefaultFullHttpRequest;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpHeaderValues;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpRequest;
import io.netty.handler.codec.http.HttpVersion;
import io.netty.handler.codec.http.cookie.ClientCookieEncoder;
import io.netty.handler.codec.http.cookie.DefaultCookie;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.util.InsecureTrustManagerFactory;
import io.netty.util.CharsetUtil;

import java.net.URI;

import javax.net.ssl.SSLException;

/**
 * A simple HTTP client that prints out the content of the HTTP response to
 * {@link System#out} to test {@link HttpSnoopServer}.
 */
public final class HttpSnoopClient {

  static final String URL = System.getProperty("url", "http://127.0.0.1:8080/");

  public static void main(String[] args) throws Exception {
    URI uri = new URI(URL);
    String scheme = uri.getScheme() == null ? "http" : uri.getScheme();
    String host = uri.getHost() == null ? "127.0.0.1" : uri.getHost();
    int port = uri.getPort();
    if (port == -1) {
      if ("http".equalsIgnoreCase(scheme)) {
        port = 80;
      } else if ("https".equalsIgnoreCase(scheme)) {
        port = 443;
      }
    }

    if (!"http".equalsIgnoreCase(scheme) && !"https".equalsIgnoreCase(scheme)) {
      System.err.println("Only HTTP(S) is supported.");
      return;
    }

    // Configure SSL context if necessary.
    final SslContext sslCtx = setupSSL(scheme);

    // Configure the client.
    EventLoopGroup group = new NioEventLoopGroup();
    try {
      Bootstrap b = new Bootstrap();
      b.group(group).channel(NioSocketChannel.class)
          .handler(new HttpSnoopClientInitializer(sslCtx));

      // Make the connection attempt.
      Channel ch = b.connect(host, port).sync().channel();

      // Send the HTTP request.
      ch.writeAndFlush(buildRequest(uri, host));

      // Wait for the server to close the connection.
      ch.closeFuture().sync();
    } finally {
      // Shut down executor threads to exit.
      group.shutdownGracefully();
    }
  }

  private static SslContext setupSSL(final String scheme) throws SSLException {
    final boolean ssl = "https".equalsIgnoreCase(scheme);
    final SslContext sslCtx;
    if (ssl) {
      sslCtx = SslContextBuilder.forClient()
          .trustManager(InsecureTrustManagerFactory.INSTANCE).build();
    } else {
      sslCtx = null;
    }
    return sslCtx;
  }

  private static HttpRequest buildRequest(final URI uri, final String host) {
    // Prepare the HTTP request.
    FullHttpRequest request = new DefaultFullHttpRequest(HttpVersion.HTTP_1_1,
        HttpMethod.GET, uri.getRawPath());
    request.headers().set(HttpHeaderNames.HOST, host);
    request.headers().set(HttpHeaderNames.CONNECTION, HttpHeaderValues.CLOSE);
    request.headers().set(HttpHeaderNames.ACCEPT_ENCODING,
        HttpHeaderValues.GZIP);
    request.headers().set(HttpHeaderNames.CONTENT_TYPE,
        "application/json; charset=UTF-8");

    // Set some example cookies.
    request.headers().set(HttpHeaderNames.COOKIE,
        ClientCookieEncoder.STRICT.encode(
            new DefaultCookie("my-cookie", "foo"),
            new DefaultCookie("another-cookie", "bar")));

    // set content
    final ByteBuf buffer = request.content().clear();
    final String json = "hello, json";
    int p0 = buffer.writerIndex();
    buffer.writeBytes(json.getBytes(CharsetUtil.UTF_8));
    int p1 = buffer.writerIndex();
    request.headers().set(HttpHeaderNames.CONTENT_LENGTH,
        Integer.toString(p1 - p0));

    return request;
  }
}
