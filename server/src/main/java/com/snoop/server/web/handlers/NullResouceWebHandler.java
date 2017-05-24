package com.snoop.server.web.handlers;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class NullResouceWebHandler extends AbastractWebHandler {

  public NullResouceWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  @Override
  protected FullHttpResponse handleDeletion() {
    return onDelete();
  }

  private FullHttpResponse onGet() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.OK);
  }

  private FullHttpResponse onCreate() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.CREATED);
  }

  private FullHttpResponse onDelete() {
    return newResponse(HttpResponseStatus.NO_CONTENT);
  }

  private FullHttpResponse onUpdate() {
    return newResponse(HttpResponseStatus.NO_CONTENT);
  }
}
