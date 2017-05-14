package com.snoop.server.web.handlers;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.Profile;
import com.snoop.server.db.model.TakeQuestionRequest;
import com.snoop.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class TakeQuestionWebHandler extends AbastractWebHandler
    implements WebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(SigninWebHandler.class);


  public TakeQuestionWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  private FullHttpResponse onCreate() {
    /* from json */
    final TakeQuestionRequest fromJson;
    try {
      fromJson = newInstanceFromRequest(TakeQuestionRequest.class);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify profile */
    final FullHttpResponse resp = verifyRequest(fromJson, getRespBuf());
    if (resp != null) {
      return resp;
    }

    Session session = null;
    Transaction txn = null;

    /* query DB copy */
    Profile fromDB = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      fromDB = (Profile) session.get(Profile.class, fromJson.getUid());
      txn.commit();
      if (fromDB == null) {
        appendln(String.format("Nonexistent profile for user ('%d')",
            fromJson.getUid()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }

    /**
     * avoid updating fields (e.g. those not explicitly set by Json) to NULL
     */
    fromDB.setTakeQuestion(fromJson.getTakeQuestion());

    try {
      session = getSession();
      txn = session.beginTransaction();
      session.update(fromDB);
      txn.commit();
      appendln(toIdJson("uid", fromJson.getUid()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse verifyRequest(TakeQuestionRequest request,
      ByteArrayDataOutput respBuf) {
    if (request == null) {
      appendln("No profile or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (request.getUid() == null) {
      appendln("No profile id specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(request.getTakeQuestion())) {
      appendln("No takeQuestion specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }
}
