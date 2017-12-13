package com.snoop.server.web.handlers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;

public class QaStatWebHandler extends AbastractWebHandler implements WebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(QaStatWebHandler.class);

  public QaStatWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new QaStatFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
  }

  private FullHttpResponse onGet() {
    Long id = null;

    try {
      id = Long.parseLong(getPathParser().getPathStream().nextToken());
    } catch (NumberFormatException e) {
      appendln("Incorrect id format.");
      return newClientErrorResponse(e, LOG);
    }

    try {
      return newResponseForInstance(id, "qastats", null);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }
}
