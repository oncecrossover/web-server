package com.gibbon.peeq.snoop;

import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Session;

import com.gibbon.peeq.db.util.HibernateUtil;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;

import static io.netty.handler.codec.http.HttpMethod.GET;
import static io.netty.handler.codec.http.HttpMethod.POST;
import static io.netty.handler.codec.http.HttpMethod.DELETE;
import static io.netty.handler.codec.http.HttpMethod.PUT;

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
      return null;
    }
  }

  protected abstract FullHttpResponse handleRetrieval();

  protected abstract FullHttpResponse handleCreation();

  protected abstract FullHttpResponse handleUpdate();

  protected abstract FullHttpResponse handleDeletion();
}
