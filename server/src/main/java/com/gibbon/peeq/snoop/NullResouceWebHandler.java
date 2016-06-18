package com.gibbon.peeq.snoop;

import org.apache.commons.lang3.text.StrBuilder;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class NullResouceWebHandler extends AbastractPeeqWebHandler {

  public NullResouceWebHandler(ResourceURIParser uriParser, StrBuilder respBuf,
      ChannelHandlerContext ctx, FullHttpRequest request) {
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
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  private FullHttpResponse onCreate() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  private FullHttpResponse onDelete() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  private FullHttpResponse onUpdate() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }
}
