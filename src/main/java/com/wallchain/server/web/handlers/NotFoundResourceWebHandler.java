package com.wallchain.server.web.handlers;

import com.google.common.io.ByteArrayDataOutput;
import com.wallchain.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class NotFoundResourceWebHandler extends AbastractWebHandler {

  public NotFoundResourceWebHandler(ResourcePathParser pathParser,
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
    appendNotFoundResource();
    return newResponse(HttpResponseStatus.NOT_FOUND);
  }

  private FullHttpResponse onCreate() {
    appendNotFoundResource();
    return newResponse(HttpResponseStatus.NOT_FOUND);
  }

  private FullHttpResponse onDelete() {
    appendNotFoundResource();
    return newResponse(HttpResponseStatus.NOT_FOUND);
  }

  private FullHttpResponse onUpdate() {
    appendNotFoundResource();
    return newResponse(HttpResponseStatus.NOT_FOUND);
  }

  private void appendNotFoundResource() {
    final String resourceName = getPathParser().getPathStream().getTouchedPath();
    appendln(String.format("Not found the resource '%s'", resourceName));
  }
}
