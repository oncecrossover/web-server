package com.gibbon.peeq.handlers;


import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.Snoop;
import com.gibbon.peeq.db.util.SnoopUtil;
import com.gibbon.peeq.util.FilterParamParser;
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.QueryParamsParser;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class SnoopFilterWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(SnoopFilterWebHandler.class);

  public SnoopFilterWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request,
        new FilterParamParser(request.uri()));
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
     return onQuery();
  }

  private Map<String, List<String>> getParams() {
    QueryParamsParser parser = new QueryParamsParser(getRequest().uri());
    return parser.params();
  }

  private FullHttpResponse onQuery() {
    Transaction txn = null;
    try {
      Session session = getSession();
      txn = session.beginTransaction();

      /* query */
      String resultJson = getResultJson(
          SnoopUtil.getSnoops(session, getParams(), false));

      txn.commit();

      /* buffer result */
      appendln(resultJson);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private String getResultJson(final List<Snoop> list) throws Exception {
    loadAvatarsFromObjectStore(list);
    return listToJsonString(list);
  }

  private void loadAvatarsFromObjectStore(List<Snoop> snoops)
      throws Exception {
    for (Snoop snoop : snoops) {
      if (StringUtils.isBlank(snoop.getResponderAvatarUrl())) {
        continue;
      }

      final ObjectStoreClient osc = new ObjectStoreClient();
      final byte[] readContent = osc
          .readAvatarImage(snoop.getResponderAvatarUrl());
      if (readContent != null) {
        snoop.setResponderAvatarImage(readContent);
      }
    }
  }
}
