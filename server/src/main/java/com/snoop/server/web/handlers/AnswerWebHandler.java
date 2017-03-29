package com.snoop.server.web.handlers;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;

public class AnswerWebHandler extends AbastractWebHandler
    implements WebHandler {

  public AnswerWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return forward();
  }

  private FullHttpResponse forward() {
    final WebHandler pwh = new AnswerFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());
    return pwh.handle();
  }
}
