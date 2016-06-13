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

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.handler.codec.DecoderResult;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpUtil;
import io.netty.handler.codec.http.HttpHeaderValues;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpObject;
import io.netty.handler.codec.http.QueryStringDecoder;
import io.netty.handler.codec.http.cookie.Cookie;
import io.netty.handler.codec.http.cookie.ServerCookieDecoder;
import io.netty.handler.codec.http.cookie.ServerCookieEncoder;
import io.netty.util.CharsetUtil;

import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.text.StrBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static io.netty.handler.codec.http.HttpResponseStatus.*;
import static io.netty.handler.codec.http.HttpVersion.*;

public class HttpSnoopServerHandler
    extends SimpleChannelInboundHandler<HttpObject> {
  private static final Logger LOG = LoggerFactory
      .getLogger(HttpSnoopServerHandler.class);
  private FullHttpRequest request;
  /** Buffer that stores the response content */
  private final StrBuilder buf = new StrBuilder();

  @Override
  public void channelReadComplete(ChannelHandlerContext ctx) {
    ctx.flush();
  }

  @Override
  protected void channelRead0(ChannelHandlerContext ctx, HttpObject msg) {
    processRequest(ctx, msg);
  }

  private void processRequest(ChannelHandlerContext ctx, HttpObject msg) {
    request = (FullHttpRequest) msg;

    if (HttpUtil.is100ContinueExpected(request)) {
      send100Continue(ctx);
    }

    QueryStringDecoder queryStringDecoder = new QueryStringDecoder(
        request.uri());
    try {
      new WebPeeqHandler(new ParameterParser(queryStringDecoder), buf)
          .handle(ctx, request);
    } catch (Exception e) {
      LOG.warn(e.toString());
    }

    /* read content from request */
    readContent();

    if (!writeResponse(ctx)) {
      // If keep-alive is off, close the connection once the content is
      // fully written.
      ctx.writeAndFlush(Unpooled.EMPTY_BUFFER)
          .addListener(ChannelFutureListener.CLOSE);
    }
  }

  private void printHeaderInfo() {
    buf.setLength(0);
    buf.appendln("WELCOME TO THE WILD WILD WEB SERVER");
    buf.appendln("===================================");

    buf.append("VERSION: ").append(request.protocolVersion()).appendNewLine();
    buf.append("HOSTNAME: ")
        .append(request.headers().get(HttpHeaderNames.HOST, "unknown"))
        .appendNewLine();
    buf.append("REQUEST_URI: ").append(request.uri()).appendNewLine()
        .appendNewLine();

    for (Map.Entry<String, String> h : request.headers()) {
      CharSequence key = h.getKey();
      CharSequence value = h.getValue();
      buf.append("HEADER: ").append(key).append(" = ").append(value)
          .appendNewLine();
    }
    buf.appendNewLine();
  }

  private void readContent() {
    ByteBuf content = request.content();
    if (content.isReadable()) {
      buf.appendln("CONTENT: ");
      buf.append(content.toString(CharsetUtil.UTF_8));
      buf.appendNewLine();
      appendDecoderResult(buf);
      buf.appendln("END OF CONTENT");
    }
  }

  private void printTrailingInfo() {
    if (!request.trailingHeaders().isEmpty()) {
      buf.appendNewLine();
      for (CharSequence name : request.trailingHeaders().names()) {
        for (CharSequence value : request.trailingHeaders().getAll(name)) {
          buf.append("TRAILING HEADER: ");
          buf.append(name).append(" = ").append(value).appendNewLine();
        }
      }
      buf.appendNewLine();
    }
  }

  private void appendDecoderResult(StrBuilder buf) {
    DecoderResult result = request.decoderResult();
    if (result.isSuccess()) {
      return;
    }

    buf.append(".. WITH DECODER FAILURE: ");
    buf.append(result.cause());
    buf.appendNewLine();
  }

  private boolean writeResponse(ChannelHandlerContext ctx) {
    // Decide whether to close the connection or not.
    final boolean keepAlive = HttpUtil.isKeepAlive(request);

    // Build the response object.
    final FullHttpResponse response = buildResponse();

    // set connection status
    setupConnectionStatus(keepAlive, response);

    // set cookie
    setupCookie(response);

    // Write the response.
    ctx.write(response);

    return keepAlive;
  }

  private FullHttpResponse buildResponse() {
    FullHttpResponse response = new DefaultFullHttpResponse(HTTP_1_1,
        request.decoderResult().isSuccess() ? OK : BAD_REQUEST,
        Unpooled.copiedBuffer(buf.toString(), CharsetUtil.UTF_8));

    response.headers().set(HttpHeaderNames.CONTENT_TYPE,
        "application/json; charset=UTF-8");
    return response;
  }

  private void setupConnectionStatus(final boolean keepAlive,
      final FullHttpResponse response) {
    if (keepAlive) {
      // Add 'Content-Length' header only for a keep-alive connection.
      response.headers().setInt(HttpHeaderNames.CONTENT_LENGTH,
          response.content().readableBytes());
      /**
       * Add keep alive header as per:
       * http://www.w3.org/Protocols/HTTP/1.1/draft-ietf-http-v11-spec-01.html#
       * Connection
       */
      response.headers().set(HttpHeaderNames.CONNECTION,
          HttpHeaderValues.KEEP_ALIVE);
    }
  }

  private void setupCookie(final FullHttpResponse response) {
    String cookieString = request.headers().get(HttpHeaderNames.COOKIE);
    if (cookieString != null) {
      Set<Cookie> cookies = ServerCookieDecoder.STRICT.decode(cookieString);
      if (!cookies.isEmpty()) {
        // Reset the cookies if necessary.
        for (Cookie cookie : cookies) {
          response.headers().add(HttpHeaderNames.SET_COOKIE,
              ServerCookieEncoder.STRICT.encode(cookie));
        }
      }
    }
  }

  private static void send100Continue(ChannelHandlerContext ctx) {
    FullHttpResponse response = new DefaultFullHttpResponse(HTTP_1_1, CONTINUE);
    ctx.write(response);
  }

  @Override
  public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
    cause.printStackTrace();
    request = null;
    ctx.close();
  }
}
