package com.gibbon.peeq.handlers;

import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Session;

import com.gibbon.peeq.db.util.HibernateUtil;
import com.gibbon.peeq.util.ResourceURIParser;

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

public interface PeeqWebHandler {

  public ResourceURIParser getUriParser();

  public StrBuilder getRespBuf();

  public ChannelHandlerContext getHandlerContext();

  public FullHttpRequest getRequest();

  public Session getSession();

  public FullHttpResponse handle();
}

abstract class AbastractPeeqWebHandler implements PeeqWebHandler {
  private ResourceURIParser uriParser;
  private StrBuilder respBuf;
  private ChannelHandlerContext ctx;
  private FullHttpRequest request;
  private Session session = HibernateUtil.getSessionFactory()
      .getCurrentSession();

  public AbastractPeeqWebHandler(final ResourceURIParser uriParser,
      final StrBuilder respBuf, final ChannelHandlerContext ctx,
      final FullHttpRequest request) {
    this.uriParser = uriParser;
    this.respBuf = respBuf;
    this.ctx = ctx;
    this.request = request;
  }

  public ResourceURIParser getUriParser() {
    return uriParser;
  }

  public StrBuilder getRespBuf() {
    return respBuf;
  }

  public ChannelHandlerContext getHandlerContext() {
    return ctx;
  }

  public FullHttpRequest getRequest() {
    return request;
  }

  public Session getSession() {
    return session;
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
        Unpooled.copiedBuffer(getRespBuf().toString(), CharsetUtil.UTF_8));
    getRespBuf().clear();

    response.headers().set(HttpHeaderNames.CONTENT_TYPE,
        "application/json; charset=UTF-8");
    return response;
  }

  protected void appendln(final String str) {
    getRespBuf().appendln(str);
  }

  protected abstract FullHttpResponse handleRetrieval();

  protected abstract FullHttpResponse handleCreation();

  protected abstract FullHttpResponse handleUpdate();

  protected abstract FullHttpResponse handleDeletion();

  private FullHttpResponse handleNotAllowedMethod(final HttpMethod method) {
    appendln(String.format("Method '%s' not allowed.", method.toString()));
    return newResponse(HttpResponseStatus.METHOD_NOT_ALLOWED);
  }
}
