package com.snoop.server.web;

import java.io.IOException;
import java.net.URI;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.net.ssl.SSLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Joiner;

import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
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
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;

public class MiniHttpSnoopClient {

  private static final Logger LOG = LoggerFactory
      .getLogger(MiniHttpSnoopClient.class);

  private String host;
  private int port;
  private boolean sslEnabled;
  private String uriRoot;
  private EventLoopGroup bossGroup;
  private Channel channel;
  private HttpSnoopClientInitializer httpClientInitializer;
  private AtomicBoolean channelClosed = new AtomicBoolean(false);

  public MiniHttpSnoopClient(final String host, final int port,
      final boolean sslEnabled) throws IOException {
    this.host = host;
    this.port = port;
    this.sslEnabled = sslEnabled;

    initHttpSnoopClient();
  }

  public HttpSnoopClientInitializer getHttpClientInitializer() {
    return httpClientInitializer;
  }

  private void initHttpSnoopClient() throws IOException {
    final String scheme = sslEnabled ? "https" : "http";
    uriRoot = String.format("%s://%s:%d", scheme, host, port);

    try {
      final SslContext sslCtx = sslEnabled ? setupSSL() : null;

      /* Configure the client. */
      bossGroup = new NioEventLoopGroup();
      httpClientInitializer = new HttpSnoopClientInitializer(sslCtx);

      final Bootstrap b = new Bootstrap();
      b.group(bossGroup)
          .channel(NioSocketChannel.class)
          .handler(httpClientInitializer);

      /* Make the connection attempt. */
      channel = b.connect(host, port).sync().channel();
    } catch (SSLException | InterruptedException e) {
      throw new IOException(e);
    }
  }

  private SslContext setupSSL() throws SSLException {
    final SslContext sslCtx = SslContextBuilder.forClient()
        .keyManager(SecureSnoopSslContextFactory.getClientKeyManagerFactory())
        .trustManager(
            SecureSnoopSslContextFactory.getClientTrustManagerFactory())
        .build();
    return sslCtx;
  }

  public String getHost() {
    return host;
  }

  public int getPort() {
    return port;
  }

  public boolean getSslEnabled() {
    return sslEnabled;
  }

  public boolean getChannelClosed() {
    return channelClosed.get();
  }

  void waitChannelClosed() throws InterruptedException {
    channel.closeFuture().sync().addListener(new ChannelFutureListener() {
      @Override
      public void operationComplete(ChannelFuture future) throws Exception {
        if (future.isSuccess()) {
          channelClosed.set(true);
          LOG.info("mini HttpClient channel closed ? " + channelClosed);
        } else {
          channelClosed.set(false);
          throw new Exception("failed to close mini HttpClient channel.",
              future.cause());
        }
      }
    });
  }

  public void shutDown() {
    if (bossGroup != null) {
      bossGroup.shutdownGracefully();
    }
  }

  public void sendRequest(final HttpMethod httpMethod, final String resourceUri,
      final byte[] content) {
    final String fullUri = Joiner.on("/").join(uriRoot, resourceUri);

    /* build HTTP request. */
    final HttpRequestBuilder builder = new HttpRequestBuilder();
    final HttpRequest request = builder
        .fullUri(fullUri)
        .httpMethod(httpMethod)
        .host(this.host)
        .content(content).build();

    /* Send HTTP request. */
    channel.writeAndFlush(request);

    /* Wait for the server to close the connection. */
    // channel.closeFuture().sync();
  }

  public static class HttpRequestBuilder {
    public HttpRequestBuilder() {
    }

    private HttpMethod httpMethod;
    private String fullUri;
    private String host;
    private byte[] content;

    public HttpRequestBuilder httpMethod(final HttpMethod httpMethod) {
      this.httpMethod = httpMethod;
      return this;
    }

    public HttpRequestBuilder fullUri(final String fullUri) {
      this.fullUri = fullUri;
      return this;
    }

    public HttpRequestBuilder host(final String host) {
      this.host = host;
      return this;
    }

    public HttpRequestBuilder content(final byte[] content) {
      this.content = content;
      return this;
    }

    public HttpRequest build() {

      /* Prepare the HTTP request. */
      final FullHttpRequest request = new DefaultFullHttpRequest(
          HttpVersion.HTTP_1_1, httpMethod, URI.create(fullUri).getRawPath());
      request.headers().set(HttpHeaderNames.HOST, host);
      request.headers().set(HttpHeaderNames.CONNECTION, HttpHeaderValues.CLOSE);
      request.headers().set(HttpHeaderNames.ACCEPT_ENCODING,
          HttpHeaderValues.GZIP);
      request.headers().set(HttpHeaderNames.CONTENT_TYPE,
          "application/json; charset=UTF-8");

      if (content == null) {
        return request;
      }

      /* set content */
      final ByteBuf buffer = request.content().clear();
      final int p0 = buffer.writerIndex();
      buffer.writeBytes(content);
      final int p1 = buffer.writerIndex();
      request.headers().set(HttpHeaderNames.CONTENT_LENGTH,
          Integer.toString(p1 - p0));

      return request;
    }
  }
}
