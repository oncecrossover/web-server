package com.snoop.server.web.handlers;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Date;

import javax.mail.MessagingException;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.TempPwd;
import com.snoop.server.db.model.User;
import com.snoop.server.db.util.TempPwdUtil;
import com.snoop.server.db.util.UserDBUtil;
import com.snoop.server.util.EmailUtil;
import com.snoop.server.util.ResourcePathParser;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class TempPwdWebHandler extends AbastractWebHandler
    implements WebHandler {
  private static final Logger LOG = LoggerFactory
      .getLogger(TempPwdWebHandler.class);

  public TempPwdWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  private FullHttpResponse onCreate() {
    final TempPwd fromJson;
    try {
      fromJson = newTempPwdFromRequest();
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    if (fromJson == null || fromJson.getUname() == null) {
      appendln("No uname specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* generate random pwd */
    fromJson.setPwd(EmailUtil.getRandomPwd())
            .setStatus(TempPwd.Status.PENDING.value());

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();

      /* query user */
      final User user = UserDBUtil.getUserByUname(session, fromJson.getUname(),
          false);
      if (user == null) {
        appendln(String.format("Nonexistent user ('%s')", fromJson.getUname()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }

      /* insert new temp one */
      fromJson.setUid(user.getUid());
      session.save(fromJson);

      txn.commit();

      /* send temp pwd to user by email */
      sendTempPwdToUser(user.getPrimaryEmail(), fromJson);

      appendln(toIdJson("id", fromJson.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  private void sendTempPwdToUser(final String email, final TempPwd tempPwd) {
    EmailUtil.sendTempPwd(email, tempPwd.getPwd());
  }

  private TempPwd newTempPwdFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return TempPwd.newInstance(json);
    }
    return null;
  }
}
