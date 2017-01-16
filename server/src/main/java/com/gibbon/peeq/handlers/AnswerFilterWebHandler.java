package com.gibbon.peeq.handlers;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.util.QuandaDBUtil;
import com.gibbon.peeq.model.Answer;
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class AnswerFilterWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  private static final Logger LOG = LoggerFactory
      .getLogger(AnswerFilterWebHandler.class);

  public AnswerFilterWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
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
    final List<Answer> list = QuandaDBUtil.getAnswers(
        session,
        params,
        false);

    loadAvatarsAndCoversFromObjectStore(list);
    return listToJsonString(list);
  }

  private void loadAvatarsAndCoversFromObjectStore(List<Answer> answers)
      throws Exception {
    for (Answer entity : answers) {
      final ObjectStoreClient osc = new ObjectStoreClient();
      byte[] readContent = null;
      if (!StringUtils.isBlank(entity.getAskerAvatarUrl())) {
        readContent = osc.readAvatarImage(entity.getAskerAvatarUrl());
        if (readContent != null) {
          entity.setAskerAvatarImage(readContent);
        }
      }

      if (!StringUtils.isBlank(entity.getAnswerCoverUrl())) {
        readContent = osc.readAnswerCover(entity.getAnswerCoverUrl());
        if (readContent != null) {
          entity.setAnswerCover(readContent);
        }
      }

      if (!StringUtils.isBlank(entity.getResponderAvatarUrl())) {
        readContent = osc.readAvatarImage(entity.getResponderAvatarUrl());
        if (readContent != null) {
          entity.setResponderAvatarImage(readContent);
        }
      }
    }
  }
}
