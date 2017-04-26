package com.snoop.server.web.handlers;

import java.util.List;
import java.util.Map;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.DBConf;
import com.snoop.server.db.util.DBConfDBUtil;
import com.snoop.server.util.FilterParamParser;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ConfigurationFilterWebHandler extends AbastractWebHandler
    implements WebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(ConfigurationFilterWebHandler.class);

  public ConfigurationFilterWebHandler(
      final ResourcePathParser pathParser,
      final ByteArrayDataOutput respBuf,
      final ChannelHandlerContext ctx,
      final FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request,
        new FilterParamParser(request.uri()));
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
    final List<DBConf> list = DBConfDBUtil.getDBConfs(session,
        params, false);

    return listToJsonString(list);
  }
}