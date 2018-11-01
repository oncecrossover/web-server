package com.wallchain.server.web.handlers;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.common.io.ByteArrayDataOutput;
import com.wallchain.server.db.model.User;
import com.wallchain.server.db.util.JournalUtil;
import com.wallchain.server.model.Balance;
import com.wallchain.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class BalanceWebHandler extends AbastractWebHandler
    implements WebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(BalanceWebHandler.class);

  public BalanceWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  private FullHttpResponse onGet() {
    /* get id */
    Long uid = null;
    try {
      uid = Long.parseLong(getPathParser().getPathStream().nextToken());
    } catch (NumberFormatException e) {
      appendln("Incorrect uid format.");
      return newClientErrorResponse(e, LOG);
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
        appendln(String.format("Nonexistent user ('%d')", uid));
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

    /* query balance */
    try {
      final Double amount = JournalUtil.getBalanceIgnoreNull(uid);
      final Balance instance = new Balance().setUid(uid)
          .setBalance(floorValue(amount));

      /* buffer result */
      return newResponseForInstance(uid, instance);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private double floorValue(final double amount) {
    return Math.floor(amount * 100.0) / 100.0;
  }

  private FullHttpResponse newResponseForInstance(final Long id,
      final Balance instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(String.format("Nonexistent balance for user ('%d')", id));
      return newResponse(HttpResponseStatus.NOT_FOUND);
    }
  }
}
