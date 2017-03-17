package com.gibbon.peeq.handlers;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.PcAccount;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class PcAccountWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(PcAccountWebHandler.class);

  public PcAccountWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private FullHttpResponse onUpdate() {
    /* get id */
    final String uid = getPathParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* deserialize json */
    final PcAccount fromJson;
    try {
      fromJson = newInstanceFromRequest(PcAccount.class);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify */
    FullHttpResponse resp = verifyPcAccount(fromJson, getRespBuf());
    if (resp != null) {
      return resp;
    }

    Transaction txn = null;
    Session session = null;

    /* query DB copy */
    final PcAccount fromDB;
    try {
      session = getSession();
      txn = session.beginTransaction();
      fromDB = (PcAccount) session.get(PcAccount.class, uid);
      txn.commit();
      if (fromDB == null) {
        appendln(String.format("Nonexistent PcAccount for user ('%s')", uid));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }

    /* update */
    try {
      session = getSession();
      txn = session.beginTransaction();
      fromDB.setPayTo(fromJson.getPayTo());
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

  static FullHttpResponse verifyPcAccount(
      final PcAccount pcAccount,
      final ByteArrayDataOutput respBuf) {
    if (pcAccount == null) {
      appendln("No PcAccount or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(pcAccount.getPayTo())) {
      appendln("No payTo specified in PcAccount.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }
}
