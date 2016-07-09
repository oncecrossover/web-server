package com.gibbon.peeq.handlers;

import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class NotFoundResourceWebHandler extends AbastractPeeqWebHandler {

  public NotFoundResourceWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
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
    final String resourceName = getUriParser().getPathStream().getTouchedPath();
    appendln(String.format("Not found the resource '%s'", resourceName));
  }
}
