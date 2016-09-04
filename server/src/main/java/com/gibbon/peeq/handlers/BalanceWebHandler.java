package com.gibbon.peeq.handlers;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gibbon.peeq.db.model.PcEntry;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.db.util.JournalUtil;
import com.gibbon.peeq.model.Balance;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class BalanceWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
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
      txn.rollback();
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

  private FullHttpResponse newResponseForInstance(final String id,
      final Balance instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(String.format("Nonexistent balance for user ('%s')", id));
      return newResponse(HttpResponseStatus.NOT_FOUND);
    }
  }
}
