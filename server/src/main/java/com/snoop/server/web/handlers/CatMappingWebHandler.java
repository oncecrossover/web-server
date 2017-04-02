package com.snoop.server.web.handlers;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.CatMappingEntry;
import com.snoop.server.db.util.CatMappingDBUtil;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class CatMappingWebHandler extends AbastractWebHandler
    implements WebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(CatMappingWebHandler.class);

  public CatMappingWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new CatMappingFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();

      /* buid params map */
      Map<String, List<String>> params = Maps.newHashMap();
      List<String> paramList = Lists.newArrayList();
      paramList.add(id);
      params.put("id", paramList);

      /* query */
      final List<CatMappingEntry> list = CatMappingDBUtil.getCatMappingEntries(
          session,
          params,
          false);
      txn.commit();

      /* buffer result */
      final CatMappingEntry retInstance = list.size() == 1 ? list.get(0) : null;
      return newResponseForInstance(id.toString(), "catmappings", retInstance);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private FullHttpResponse onUpdate() {
    /* get id */
    Long uid = null;
    try {
      uid = Long.parseLong(getPathParser().getPathStream().nextToken());
    } catch (NumberFormatException e) {
      appendln("Incorrect uid format.");
      return newClientErrorResponse(e, LOG);
    }

    /* deserialize json */
    List<CatMappingEntry> fromJsonList = null;
    try {
      fromJsonList = newInstanceAsListFromRequest(CatMappingEntry.class);
      if (fromJsonList == null) {
        appendln("No CatMapping entries or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify from json list */
    final FullHttpResponse resp = verifyCatMapping(fromJsonList, getRespBuf());
    if (resp != null) {
      return resp;
    }

    Transaction txn = null;
    Session session = null;

    /* prepare toDB list */
    List<CatMappingEntry> toDBList = Lists.newArrayList();
    for (final CatMappingEntry fromJson : fromJsonList) {
      CatMappingEntry fromDB = null;
      try {
        session = getSession();
        txn = session.beginTransaction();
        if (fromJson.getId() != null) { // existent one
          fromDB = (CatMappingEntry) session.get(CatMappingEntry.class,
              fromJson.getId());
          txn.commit();
          if (fromDB == null) {
            appendln(String.format("Nonexistent CatMapping for (%d, %d)",
                fromJson.getCatId(), uid));
            return newResponse(HttpResponseStatus.BAD_REQUEST);
          }
        } else { // existent one or new one
          fromDB = CatMappingDBUtil.getCatMappingEntry(session,
              fromJson.getCatId(), uid, false);
          txn.commit();
        }
      } catch (Exception e) {
        if (txn != null && txn.isActive()) {
          txn.rollback();
        }
        return newServerErrorResponse(e, LOG);
      }

      /* use uid from url, ignore that from json */
      fromJson.setUid(uid);
      if (fromDB != null) {
        fromDB.setAsIgnoreNull(fromJson);
        toDBList.add(fromDB);
      } else {
        toDBList.add(fromJson);
      }
    }

    /* persist toDB list */
    try {
      session = getSession();
      txn = session.beginTransaction();
      for (final CatMappingEntry toDB : toDBList) {
        session.saveOrUpdate(toDB);
      }
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse verifyCatMapping(
      final List<CatMappingEntry> fromJsonList,
      final ByteArrayDataOutput respBuf) {

    for (final CatMappingEntry fromJson : fromJsonList) {
      if (fromJson.getCatId() == null) {
        appendln("No catId specified.", respBuf);
        return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
      }

      if (StringUtils.isBlank(fromJson.getIsExpertise())
          && StringUtils.isBlank(fromJson.getIsInterest())) {
        appendln("Either isExpertise or isInterest must be specified.",
            respBuf);
        return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
      }
    }

    return null;
  }
}
