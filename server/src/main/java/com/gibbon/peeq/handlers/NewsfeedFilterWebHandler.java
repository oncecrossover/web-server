package com.gibbon.peeq.handlers;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.util.QuandaDBUtil;
import com.gibbon.peeq.model.Newsfeed;
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class NewsfeedFilterWebHandler extends AbastractPeeqWebHandler
implements PeeqWebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(NewsfeedFilterWebHandler.class);

  public NewsfeedFilterWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onQuery();
  }

  private FullHttpResponse onQuery() {
    Transaction txn = null;
    try {
      Session session = getSession();
      txn = session.beginTransaction();

      /* query */
      String result = getResultJson(session, getQueryParser().params());

      txn.commit();

      /* buffer result */
      appendln(result);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  private String getResultJson(
      final Session session,
      final Map<String, List<String>> params) throws Exception {
    final List<Newsfeed> list = QuandaDBUtil.getNewsfeed(
        session,
        params,
        false);

    loadAvatarsAndCoversFromObjectStore(list);
    return listToJsonString(list);
  }

  private void loadAvatarsAndCoversFromObjectStore(List<Newsfeed> list)
      throws Exception {
    for (Newsfeed entity : list) {
      if (StringUtils.isBlank(entity.getResponderAvatarUrl())) {
        continue;
      }

      final ObjectStoreClient osc = new ObjectStoreClient();
      byte[] readContent = null;
      readContent = osc.readAvatarImage(entity.getResponderAvatarUrl());
      if (readContent != null) {
        entity.setResponderAvatarImage(readContent);
      }
      readContent = osc.readAnswerCover(entity.getAnswerCoverUrl());
      if (readContent != null) {
        entity.setAnswerCover(readContent);
      }
    }
  }
}
