package com.gibbon.peeq.handlers;

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
import com.gibbon.peeq.db.model.TempPwd;
import com.gibbon.peeq.db.util.TempPwdUtil;
import com.gibbon.peeq.util.EmailUtil;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class TempPwdWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
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

    if (fromJson == null || StringUtils.isBlank(fromJson.getUid())) {
      appendln("No temp pwd info or incorrect format specified.");
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

      /* expire all pending ones */
      TempPwdUtil.expireAllPendingPwds(session, fromJson.getUid());

      /* insert new temp one */
      session.save(fromJson);

      txn.commit();

      /* send temp pwd to user by email */
      sendTempPwdToUser(fromJson);

      appendln(toIdJson("id", fromJson.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  private void sendTempPwdToUser(final TempPwd tempPwd) {
    EmailUtil.sendTempPwd(tempPwd.getUid(), tempPwd.getPwd());
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
