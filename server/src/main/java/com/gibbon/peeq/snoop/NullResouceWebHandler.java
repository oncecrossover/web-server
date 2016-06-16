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
    return onGetNull();
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreateNull();
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdNull();
  }

  @Override
  protected FullHttpResponse handleDeletion() {
    return onDelNull();
  }

  private FullHttpResponse onGetNull() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  private FullHttpResponse onCreateNull() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  private FullHttpResponse onDelNull() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  private FullHttpResponse onUpdNull() {
    appendln("No resource specified.");
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }
}
