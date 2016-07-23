package com.gibbon.peeq.handlers;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gibbon.peeq.db.model.Balance;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class BalancesWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(BalancesWebHandler.class);

  public BalancesWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
      return onGet();
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    try {
      final Session session = getSession();
      txn = session.beginTransaction();
      final Balance balance = (Balance) session.get(Balance.class, id);
      txn.commit();

      /* buffer result */
      appendBalance(id, balance);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void appendBalance(final String id, final Balance balance)
      throws JsonProcessingException {
    if (balance != null) {
      appendByteArray(balance.toJsonByteArray());
    } else {
      appendln(
          String.format("Nonexistent resource with URI: /balances/%s", id));
    }
  }
}
