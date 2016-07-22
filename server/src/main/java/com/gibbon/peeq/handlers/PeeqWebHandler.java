package com.gibbon.peeq.handlers;

import org.hibernate.Session;

import com.gibbon.peeq.db.util.HibernateUtil;
import com.gibbon.peeq.util.FilterParamParser;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.util.CharsetUtil;

import static io.netty.handler.codec.http.HttpMethod.GET;
import static io.netty.handler.codec.http.HttpMethod.POST;
import static io.netty.handler.codec.http.HttpMethod.DELETE;
import static io.netty.handler.codec.http.HttpMethod.PUT;
import static io.netty.handler.codec.http.HttpVersion.HTTP_1_1;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;

import org.slf4j.Logger;

public interface PeeqWebHandler {

  public ResourceURIParser getUriParser();

  public ByteArrayDataOutput getRespBuf();

  public ChannelHandlerContext getHandlerContext();

  public FullHttpRequest getRequest();

  public Session getSession();

  public FullHttpResponse handle();

  public Boolean willFilter();

  public Boolean  willSort();

  public Boolean  willLimit();
}

abstract class AbastractPeeqWebHandler implements PeeqWebHandler {
  private ResourceURIParser uriParser;
  private ByteArrayDataOutput respBuf;
  private ChannelHandlerContext ctx;
  private FullHttpRequest request;
  private FilterParamParser filterParamParser;

  public AbastractPeeqWebHandler(final ResourceURIParser uriParser,
      final ByteArrayDataOutput respBuf, final ChannelHandlerContext ctx,
      final FullHttpRequest request) {
    this(uriParser, respBuf, ctx, request, null);
  }

  public AbastractPeeqWebHandler(final ResourceURIParser uriParser,
      final ByteArrayDataOutput respBuf, final ChannelHandlerContext ctx,
      final FullHttpRequest request,
      final FilterParamParser filterParamParser) {
    this.uriParser = uriParser;
    this.respBuf = respBuf;
    this.ctx = ctx;
    this.request = request;
    this.filterParamParser = filterParamParser;
  }

  @Override
  public ResourceURIParser getUriParser() {
    return uriParser;
  }

  @Override
  public ByteArrayDataOutput getRespBuf() {
    return respBuf;
  }

  @Override
  public ChannelHandlerContext getHandlerContext() {
    return ctx;
  }

  @Override
  public FullHttpRequest getRequest() {
    return request;
  }

  @Override
  public Session getSession() {
    return HibernateUtil.getSessionFactory().getCurrentSession();
  }

  @Override
  public Boolean willFilter() {
    return filterParamParser.paramCount() > 0
        && filterParamParser.cotnainsKey("filter");
  }

  public Boolean willSort() {
    return false;
  }

  public Boolean willLimit() {
    return false;
  }

  protected FilterParamParser getFilterParamParser() {
    return filterParamParser;
  }

  /**
   * Dispatch request to handle CRUD(i.e. create, retrieve, update and delete)
   * of resources.
   */
  public FullHttpResponse handle() {
    if (request.method() == GET) { // retrieve
      return handleRetrieval();
    } else if (request.method() == POST) { // create
      return handleCreation();
    } else if (request.method() == PUT) { // update
      return handleUpdate();
    } else if (request.method() == DELETE) { // delete
      return handleDeletion();
    } else {
      return handleNotAllowedMethod(request.method());
    }
  }

  protected FullHttpResponse newResponse(HttpResponseStatus status) {
    FullHttpResponse response = new DefaultFullHttpResponse(HTTP_1_1, status,
        Unpooled.copiedBuffer(getRespBuf().toByteArray()));

    response.headers().set(HttpHeaderNames.CONTENT_TYPE,
        "application/json; charset=UTF-8");
    return response;
  }

  protected void appendByteArray(final byte[] byteArray) {
    getRespBuf().write(byteArray);
  }

  protected void appendln(final String str) {
    final String line = String.format("%s%n", str);
    getRespBuf().write(line.getBytes(CharsetUtil.UTF_8));
  }

  protected FullHttpResponse handleRetrieval() {
    return handleNotAllowedMethod(HttpMethod.GET);
  }

  protected FullHttpResponse handleCreation() {
    return handleNotAllowedMethod(HttpMethod.POST);
  }

  protected FullHttpResponse handleUpdate() {
    return handleNotAllowedMethod(HttpMethod.PUT);
  }

  protected FullHttpResponse handleDeletion() {
    return handleNotAllowedMethod(HttpMethod.DELETE);
  }

  private FullHttpResponse handleNotAllowedMethod(final HttpMethod method) {
    appendln(String.format("Method '%s' not allowed.", method.toString()));
    return newResponse(HttpResponseStatus.METHOD_NOT_ALLOWED);
  }

  String stackTraceToString(final Exception e) {
    Writer writer = new StringWriter();
    PrintWriter printWriter = new PrintWriter(writer);
    e.printStackTrace(printWriter);
    return writer.toString();
  }

  void stashServerError(final Exception e, final Logger LOG) {
    final String st = stackTraceToString(e);
    LOG.warn(st);
    appendln(st);
  }

  FullHttpResponse newServerErrorResponse(final Exception e, final Logger LOG) {
    stashServerError(e, LOG);
    return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
  }
}
