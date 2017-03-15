package com.gibbon.peeq.handlers;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.CoinEntry;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.db.util.CoinDBUtil;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class CoinWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(CoinWebHandler.class);

  public CoinWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  private FullHttpResponse onGet() {
    /* get uid */
    final String uid = getPathParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* query user */
    Transaction txn = null;
    Session session = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final User retInstance = (User) session.get(User.class, uid);
      txn.commit();

      if (retInstance == null) {
        appendln(String.format("Nonexistent user ('%s')", uid));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* query coins */
    try {
      session = getSession();
      final int amount = CoinDBUtil.getCoinsIgnoreNull(uid, session, true);
      final CoinEntry instance = new CoinEntry().setUid(uid)
          .setAmount(amount);

      /* buffer result */
      return newResponseForInstance(uid, "coins", instance);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  @Override
  protected FullHttpResponse handleCreation() {
    final CoinEntry fromJson;
    try {
      fromJson = newInstanceFromRequest(CoinEntry.class);
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
      final CoinEntry instance,
      final ByteArrayDataOutput respBuf) {
    if (instance == null) {
      appendln("No coin entry or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(instance.getUid())) {
      appendln("No uid specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (instance.getAmount() == null || instance.getAmount() < 0) {
      appendln("No amount or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }
}
