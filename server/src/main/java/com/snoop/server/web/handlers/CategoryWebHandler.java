package com.snoop.server.web.handlers;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.Category;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class CategoryWebHandler extends AbastractWebHandler
    implements WebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(CategoryWebHandler.class);

  public CategoryWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new CategoryFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final Category retInstance = (Category) session.get(Category.class,
          Long.parseLong(id));
      txn.commit();

      /* buffer result */
      return newResponseForInstance(id, "categories", retInstance);
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }


  private FullHttpResponse onCreate() {
    final Category fromJson;
    try {
      fromJson = newInstanceFromRequest(Category.class);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* very */
    final FullHttpResponse resp= verifyInstance(fromJson, getRespBuf());
    if ( resp != null) {
      return resp;
    }

    Transaction txn = null;
    Session session = null;
    try {
      session = getSession();
      txn = session.beginTransaction();

      session.save(fromJson);
      txn.commit();
      appendln(toIdJson("id", fromJson.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  static FullHttpResponse verifyInstance(
      final Category instance,
      final ByteArrayDataOutput respBuf) {
    if (instance == null) {
      appendln("No category or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(instance.getName())) {
      appendln("No name specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }

  private FullHttpResponse onUpdate() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* deserialize json */
    final Category fromJson;
    try {
      fromJson = newInstanceFromRequest(Category.class);
      if (fromJson == null) {
        appendln("No category or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Transaction txn = null;
    Session session = null;
    /**
     * query to get DB copy to avoid updating fields (e.g. value of which not
     * set by Json) to NULL
     */
    final Category fromDB;
    try {
      session = getSession();
      txn = session.beginTransaction();
      fromDB = (Category) session.get(Category.class, Long.parseLong(id));
      txn.commit();
      if (fromDB == null) {
        appendln(String.format("Nonexistent category for user ('%s')", id));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }

    /* use id from url, ignore that from json */
    fromJson.setId(Long.parseLong(id));
    fromDB.setAsIgnoreNull(fromJson);
    try {
      session = getSession();
      txn = session.beginTransaction();
      session.update(fromDB);
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }
}
