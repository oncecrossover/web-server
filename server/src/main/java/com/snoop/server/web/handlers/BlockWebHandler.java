package com.snoop.server.web.handlers;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.BlockEntry;
import com.snoop.server.db.model.ReportEntry;
import com.snoop.server.db.model.User;
import com.snoop.server.db.util.BlockDBUtil;
import com.snoop.server.db.util.UserDBUtil;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class BlockWebHandler extends AbastractWebHandler implements WebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(BlockEntry.class);

  public BlockWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new BlockFilterWebHandler(
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
    /* get user id */
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
      final BlockEntry retInstance = (BlockEntry) session.get(BlockEntry.class,
          id);
      txn.commit();

      /* buffer result */
      return newResponseForInstance(id.toString(), "blocks", retInstance);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse onCreate() {
    final BlockEntry fromJson;
    try {
      fromJson = newInstanceFromRequest(BlockEntry.class);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* very */
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
      final BlockEntry fromDB = BlockDBUtil.getBlockEntry(session,
          fromJson.getUid(), fromJson.getBlockeeId(), false);

      if (fromDB == null) { /* new block */
        session.save(fromJson);
      } else { /* existing block */
        fromDB.setAsIgnoreNull(fromJson);
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

  private FullHttpResponse verifyInstance(final BlockEntry instance,
      final ByteArrayDataOutput respBuf) {
    if (instance == null) {
      appendln("No block or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getUid() == null) {
      appendln("No uid specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getBlockeeId() == null) {
      appendln("No blockee id specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getBlocked() == null) {
      appendln("No blocked status specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getUid() == instance.getBlockeeId()) {
      appendln("A user can't block her/himself.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }
    return null;
  }
}
