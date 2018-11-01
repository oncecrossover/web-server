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
package com.wallchain.server.web;

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
import io.netty.handler.codec.http.HttpObject;
import io.netty.handler.codec.http.cookie.Cookie;
import io.netty.handler.codec.http.cookie.ServerCookieDecoder;
import io.netty.handler.codec.http.cookie.ServerCookieEncoder;
import io.netty.util.CharsetUtil;

import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.google.common.io.ByteStreams;
import com.wallchain.server.util.ResourcePathParser;
import com.wallchain.server.web.handlers.AnswerWebHandler;
import com.wallchain.server.web.handlers.BalanceWebHandler;
import com.wallchain.server.web.handlers.BlockWebHandler;
import com.wallchain.server.web.handlers.BulkDataWebHandler;
import com.wallchain.server.web.handlers.CatMappingWebHandler;
import com.wallchain.server.web.handlers.CategoryWebHandler;
import com.wallchain.server.web.handlers.CoinWebHandler;
import com.wallchain.server.web.handlers.ConfigurationWebHandler;
import com.wallchain.server.web.handlers.FollowWebHandler;
import com.wallchain.server.web.handlers.NewsfeedWebHandler;
import com.wallchain.server.web.handlers.NotFoundResourceWebHandler;
import com.wallchain.server.web.handlers.NullResouceWebHandler;
import com.wallchain.server.web.handlers.PcAccountWebHandler;
import com.wallchain.server.web.handlers.PcEntryWebHandler;
import com.wallchain.server.web.handlers.ProfileWebHandler;
import com.wallchain.server.web.handlers.PromoWebHandler;
import com.wallchain.server.web.handlers.QaStatWebHandler;
import com.wallchain.server.web.handlers.QaTransactionWebHandler;
import com.wallchain.server.web.handlers.QuandaWebHandler;
import com.wallchain.server.web.handlers.QuestionWebHandler;
import com.wallchain.server.web.handlers.ReportWebHandler;
import com.wallchain.server.web.handlers.ResetPwdWebHandler;
import com.wallchain.server.web.handlers.SigninWebHandler;
import com.wallchain.server.web.handlers.SnoopWebHandler;
import com.wallchain.server.web.handlers.TakeQuestionWebHandler;
import com.wallchain.server.web.handlers.TempPwdWebHandler;
import com.wallchain.server.web.handlers.ThumbWebHandler;
import com.wallchain.server.web.handlers.UserWebHandler;

import static io.netty.handler.codec.http.HttpResponseStatus.*;
import static io.netty.handler.codec.http.HttpVersion.*;

public class HttpSnoopServerHandler
    extends SimpleChannelInboundHandler<HttpObject> {
  private static final Logger LOG = LoggerFactory
      .getLogger(HttpSnoopServerHandler.class);
  private FullHttpRequest request;
  /* Buffer that stores the response content */
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

    LOG.info("http/https {} request uri: {}", request.method(), request.uri());

    final ResourcePathParser pathParser = new ResourcePathParser(request.uri());
    writeResponse(ctx, dispatchRequest(pathParser, ctx));
    ctx.writeAndFlush(Unpooled.EMPTY_BUFFER)
       .addListener(ChannelFutureListener.CLOSE);
  }

  private FullHttpResponse dispatchRequest(final ResourcePathParser pathParser,
      final ChannelHandlerContext ctx) {
    final ByteArrayDataOutput respBuf = ByteStreams.newDataOutput();
    final String resourceName = pathParser.getPathStream().nextToken();

    /* handle request like http://<host>:<port> or http://<host>:<port>/ */
    if (StringUtils.isEmpty(resourceName)) {
      return new NullResouceWebHandler(
          pathParser,
          respBuf,
          ctx,
          request).handle();
    }

    switch (resourceName) {
      case "users":
        return new UserWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "signin":
        return new SigninWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "profiles":
        return new ProfileWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "quandas":
        return new QuandaWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "snoops":
        return new SnoopWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "pcentries":
        return new PcEntryWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "balances":
        return new BalanceWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "qatransactions":
        return new QaTransactionWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "newsfeeds":
        return new NewsfeedWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "temppwds":
        return new TempPwdWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "resetpwd":
        return new ResetPwdWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "questions":
        return new QuestionWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "answers":
        return new AnswerWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "takeq":
        return new TakeQuestionWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "bulkdata":
        return new BulkDataWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "categories":
        return new CategoryWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "catmappings":
        return new CatMappingWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "coins":
        return new CoinWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "pcaccounts":
        return new PcAccountWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "configurations":
        return new ConfigurationWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "reports":
        return new ReportWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "blocks":
        return new BlockWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "follows":
        return new FollowWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "thumbs":
        return new ThumbWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "qastats":
        return new QaStatWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      case "promos":
        return new PromoWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
      default:
        return new NotFoundResourceWebHandler(
            pathParser,
            respBuf,
            ctx,
            request).handle();
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

  private boolean writeResponse(ChannelHandlerContext ctx,
      final FullHttpResponse response) {
    // Decide whether to close the connection or not.
    final boolean keepAlive = HttpUtil.isKeepAlive(request);

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
