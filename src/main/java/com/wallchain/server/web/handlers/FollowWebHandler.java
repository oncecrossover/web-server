package com.wallchain.server.web.handlers;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.wallchain.server.db.model.FollowEntry;
import com.wallchain.server.db.util.FollowDBUtil;
import com.wallchain.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class FollowWebHandler extends AbastractWebHandler implements WebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(FollowWebHandler.class);

  public FollowWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new FollowFilterWebHandler(
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
      final FollowEntry retInstance = (FollowEntry) session.get(FollowEntry.class,
          id);
      txn.commit();

      /* buffer result */
      return newResponseForInstance(id.toString(), "follows", retInstance);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse onCreate() {
    final FollowEntry fromJson;
    try {
      fromJson = newInstanceFromRequest(FollowEntry.class);
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
      final FollowEntry fromDB = FollowDBUtil.getFollowEntry(session,
          fromJson.getUid(), fromJson.getFolloweeId(), false);

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

  private FullHttpResponse verifyInstance(final FollowEntry instance,
      final ByteArrayDataOutput respBuf) {
    if (instance == null) {
      appendln("No follow or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getUid() == null) {
      appendln("No uid specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getFolloweeId() == null) {
      appendln("No followee id specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getFollowed() == null) {
      appendln("No followed status specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getUid() == instance.getFolloweeId()) {
      appendln("A user can't follow her/himself.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }
    return null;
  }
}
