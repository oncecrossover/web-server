package com.gibbon.peeq.handlers;

import java.io.IOException;
import java.util.Date;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.util.ObjectStoreClient;
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
    PeeqWebHandler pwh = new QuandasFilterWebHandler(getUriParser(),
        getRespBuf(), getHandlerContext(), getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
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
    /* get id */
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

      setAnswerAudio(quanda);

      /* buffer result */
      appendQuandaln(id, quanda);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void setAnswerAudio(final Quanda quanda) {
    if (quanda == null) {
      return;
    }

    final byte[] readContent = readAnswerAudio(quanda);
    if (readContent != null) {
      quanda.setAnswerAudio(readContent);
    }
  }

  private byte[] readAnswerAudio(final Quanda quanda) {
    ObjectStoreClient osc = new ObjectStoreClient();
    try {
      return osc.readAnswerAudio(quanda.getAnswerUrl());
    } catch (Exception e) {
      LOG.warn(super.stackTraceToString(e));
    }
    return null;
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
    /* get id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* deserialize json */
    final Quanda fromJson;
    try {
      fromJson = newQuandaFromRequest();
      if (fromJson == null) {
        appendln("No quanda or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Transaction txn = null;
    /*
     * query to get DB copy to avoid updating fields (not explicitly set by
     * Json) to NULL
     */
    Quanda fromDB = null;
    try {
      txn = getSession().beginTransaction();
      fromDB = (Quanda) getSession().get(Quanda.class, Long.parseLong(id));
      txn.commit();
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }

    /* ignore id from json */
    fromJson.setId(Long.parseLong(id));
    if (fromDB != null) {
      fromDB.setAsIgnoreNull(fromJson);
      /* update updatedTime */
      fromDB.setUpdatedTime(new Date());
    }
    setAnswerUrl(fromDB);

    try {
      txn = getSession().beginTransaction();
      getSession().update(fromDB);
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void setAnswerUrl(final Quanda fromDB) {
    final String url = saveAnswerAudio(fromDB);
    if (url != null) {
      fromDB.setAnswerUrl(url);
    }
  }

  private String saveAnswerAudio(final Quanda fromDB) {
    ObjectStoreClient osc = new ObjectStoreClient();
    try {
      return osc.saveAnswerAudio(fromDB);
    } catch (Exception e) {
      LOG.warn(super.stackTraceToString(e));
    }
    return null;
  }

  private FullHttpResponse onCreate() {
    final Quanda fromJson;
    try {
      fromJson = newQuandaFromRequest();
      if (fromJson == null) {
        appendln("No quanda or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* set time */
    final Date now = new Date();
    fromJson.setCreatedTime(now);
    fromJson.setUpdatedTime(now);

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      getSession().save(fromJson);
      txn.commit();
      appendln(String.format("New resource created with URI: /quandas/%s",
          fromJson.getId()));
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