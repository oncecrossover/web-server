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
import com.snoop.server.db.model.User;
import com.snoop.server.db.util.UserDBUtil;
import com.snoop.server.util.ResourcePathParser;
import com.snoop.server.util.UserUtil;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class SigninWebHandler extends AbastractWebHandler
    implements WebHandler {

  private static final Logger LOG = LoggerFactory
      .getLogger(SigninWebHandler.class);

  public SigninWebHandler(
      ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  static FullHttpResponse verifyUser(final User user,
      final ByteArrayDataOutput respBuf) {

    if (user == null) {
      appendln("No user or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(user.getUname())) {
      appendln("No username specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(user.getPwd())) {
      appendln("No password specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }

  private FullHttpResponse onCreate() {
    /* from json */
    final User fromJson;
    try {
      fromJson = newIntanceFromRequest();
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify user */
    final FullHttpResponse resp = verifyUser(fromJson, getRespBuf());
    if (resp != null) {
      return resp;
    }

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();

      /* query encoded pwd */
      final User fromDB = UserDBUtil.getUserWithPwdAndUid(
          session,
          fromJson.getUname(), false);

      /* commit transaction */
      txn.commit();

      /* return */
      if (fromDB == null) {
        appendln(String.format("Nonexistent user '%s'", fromJson.getUname()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      } else if (UserUtil.checkPassword(fromJson.getPwd(), fromDB.getPwd())) {
        appendln(toIdJson("uid", fromDB.getUid()));
        return newResponse(HttpResponseStatus.CREATED);
      } else {
        appendln("User id and password do not match.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private User newIntanceFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return User.newInstance(json);
    }
    return null;
  }
}
