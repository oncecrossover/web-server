package com.snoop.server.web.handlers;

import java.io.IOException;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.Profile;
import com.snoop.server.util.ResourcePathParser;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
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
    final Profile fromJson;
    try {
      fromJson = newIntanceFromRequest();
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify profile */
    final FullHttpResponse resp = verifyProfile(fromJson, getRespBuf());
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
    fromDB.setAsIgnoreNull(fromJson);

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

  private FullHttpResponse verifyProfile(Profile profile,
      ByteArrayDataOutput respBuf) {
    if (profile == null) {
      appendln("No profile or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (profile.getUid() == null) {
      appendln("No profile id specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(profile.getTakeQuestion())) {
      appendln("No takeQuestion specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }

  private Profile newIntanceFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return Profile.newInstance(json);
    }
    return null;
  }
}
