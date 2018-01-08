package com.snoop.server.web.handlers;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.PromoEntry;
import com.snoop.server.db.util.PromoDBUtil;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import com.snoop.server.web.handlers.PromoFilterWebHandler;

public class PromoWebHandler extends AbastractWebHandler implements WebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(PromoWebHandler.class);

  public PromoWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new PromoFilterWebHandler(
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

  private FullHttpResponse onGet() {
    Long id = null;

    try {
      id = Long.parseLong(getPathParser().getPathStream().nextToken());
    } catch (NumberFormatException e) {
      appendln("Incorrect id format.");
      return newClientErrorResponse(e, LOG);
    }

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final PromoEntry retInstance = (PromoEntry) session.get(PromoEntry.class,
          id);
      txn.commit();

      /* buffer result */
      return newResponseForInstance(id.toString(), "promos", retInstance);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse onCreate() {
    final PromoEntry fromJson;
    try {
      fromJson = newInstanceFromRequest(PromoEntry.class);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify */
    final FullHttpResponse resp = verifyInstance(fromJson, getRespBuf());
    if (resp != null) {
      return resp;
    }

    /* save or update */
    Transaction txn = null;
    Session session = null;
    try {
      session = getSession();
      txn = session.beginTransaction();

      /* query */
      final PromoEntry fromDB = PromoDBUtil.getPromo(session,
          fromJson.getUid(), fromJson.getCode(), false);

      if (fromDB == null) { /* new entry */
        session.save(fromJson);
      } else { /* existing entry */
        fromDB.setAsIgnoreNull(fromJson);
        fromJson.setId(fromDB.getId());
        session.update(fromDB);
      }
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

  private FullHttpResponse verifyInstance(final PromoEntry instance,
      final ByteArrayDataOutput respBuf) {
    if (instance == null) {
      appendln("No promo or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getUid() == null) {
      appendln("No uid specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getCode() == null) {
      appendln("No code specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }
}
