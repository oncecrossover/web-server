package com.gibbon.peeq.handlers;

import java.io.IOException;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.util.ResourceURIParser;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.util.CharsetUtil;

public class QuandasWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(QuandasWebHandler.class);

  public QuandasWebHandler(ResourceURIParser uriParser, StrBuilder respBuf,
      ChannelHandlerContext ctx, FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private FullHttpResponse onGet() {
    /* get quanda id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      final Quanda quanda = (Quanda) getSession().get(Quanda.class,
          Long.parseLong(id));
      txn.commit();

      /* quanda queried */
      appendQuandaln(id, quanda);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      /* rollback */
      txn.rollback();
      /* server error */
      String st = stackTraceToString(e);
      LOG.warn(st);
      appendln(st);
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private void appendQuandaln(final String id, final Quanda quanda)
      throws JsonProcessingException {
    if (quanda != null) {
      appendln(quanda.toJson());
    } else {
      appendln(String.format("Nonexistent resource with URI: /quandas/%s", id));
    }
  }

  private FullHttpResponse onUpdate() {
    /* get quanda id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    final Quanda quanda;
    try {
      quanda = newQuandaFromRequest();
      if (quanda == null) {
        appendln("No quanda or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      /* server error */
      String st = stackTraceToString(e);
      LOG.warn(st);
      appendln(st);
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }

    /*
     * using the id specified in uri, ignore id in json
     */
    quanda.setId(Long.parseLong(id));

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      getSession().update(quanda);
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      /* rollback */
      txn.rollback();
      /* server error */
      String st = stackTraceToString(e);
      LOG.warn(st);
      appendln(st);
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private FullHttpResponse onCreate() {
    final Quanda quanda;
    try {
      quanda = newQuandaFromRequest();
      if (quanda == null) {
        appendln("No quanda or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      /* server error */
      String st = stackTraceToString(e);
      LOG.warn(st);
      appendln(st);
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      getSession().save(quanda);
      txn.commit();
      appendln(String.format("New resource created with URI: /quandas/%s",
          quanda.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (Exception e) {
      /* rollback */
      txn.rollback();
      /* server error */
      String st = stackTraceToString(e);
      LOG.warn(st);
      appendln(st);
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private Quanda newQuandaFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final String json = content.toString(CharsetUtil.UTF_8);
      return Quanda.newQuanda(json);
    }
    return null;
  }

}
