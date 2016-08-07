package com.gibbon.peeq.handlers;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gibbon.peeq.db.model.Balance;
import com.gibbon.peeq.db.util.JournalUtil;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class BalanceWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(BalanceWebHandler.class);

  public BalanceWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String uid = getUriParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    try {
      final Double balance = JournalUtil.getBalance(getSession(), uid);
      if (balance == null) {
        appendln(String.format("Nonexistent balance for user ('%s')", uid));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }

      /* buffer result */
      appendNewInstance(uid, new Balance().setUid(uid).setBalance(balance));
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private void appendNewInstance(final String id, final Balance instance)
      throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
    } else {
      appendln(String.format("Nonexistent balance for user ('%s')", id));
    }
  }
}
