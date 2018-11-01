package com.wallchain.server.web.handlers;

import org.hibernate.Session;

import com.google.common.io.ByteArrayDataOutput;
import com.wallchain.server.util.QueryParamsParser;
import com.wallchain.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;

public interface WebHandler {

  public ResourcePathParser getPathParser();

  public QueryParamsParser getQueryParser();

  public ByteArrayDataOutput getRespBuf();

  public ChannelHandlerContext getHandlerContext();

  public FullHttpRequest getRequest();

  public Session getSession();

  public FullHttpResponse handle();

  public Boolean willFilter();

  public Boolean  willSort();

  public Boolean  willLimit();
}