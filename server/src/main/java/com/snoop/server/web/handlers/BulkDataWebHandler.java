package com.snoop.server.web.handlers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;

public class BulkDataWebHandler extends AbastractWebHandler
    implements WebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(BulkDataWebHandler.class);

  public BulkDataWebHandler(
      final ResourcePathParser pathParser,
      final ByteArrayDataOutput respBuf,
      final ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return forward();
  }

  private FullHttpResponse forward() {
    WebHandler pwh = new BulkDataFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());
    return pwh.handle();
  }
}
