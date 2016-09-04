package com.gibbon.peeq.handlers;

import java.io.IOException;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.db.util.TempPwdUtil;
import com.gibbon.peeq.model.PwdEntry;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ResetPwdWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  private static final Logger LOG = LoggerFactory
      .getLogger(ResetPwdWebHandler.class);

  public ResetPwdWebHandler(ResourcePathParser pathParser, ByteArrayDataOutput respBuf,
      ChannelHandlerContext ctx, FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  private FullHttpResponse onCreate() {
    /* get user id */
    final String uid = getPathParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* deserialize json */
    final PwdEntry fromJson;
    try {
      fromJson = newIntanceFromRequest();
      if (fromJson == null) {
        appendln("No pwd entry or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
    /* use uid from url, ignore that from json */
    fromJson.setUid(uid);

    /* verify pwd entry */
    final FullHttpResponse resp = verifyPwdEntry(fromJson);
    if (resp != null) {
      return resp;
    }

    Transaction txn = null;
    Session session = null;
    /* query DB copy */
    User fromDB = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      fromDB = (User) getSession().get(User.class, uid);
      txn.commit();
      if (fromDB == null) {
        appendln(String.format("Nonexistent user ('%s') in the DB", uid));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }

    try {
      session = getSession();
      txn = session.beginTransaction();

      /* verify temp pwd */
      if (tempPwdExists4User(session, fromJson)) {
        /* use new pwd */
        assignNewPwd(fromJson, fromDB);
        /* expire all temp pwds */
        TempPwdUtil.expireAllPendingPwds(session, fromJson.getUid());
      } else {
        appendln(String.format("Invalid temp pwd ('%s') for user ('%s')",
            fromJson.getTempPwd(), fromJson.getUid()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }

      /* update */
      session.update(fromDB);
      txn.commit();
      appendln(toIdJson("uid", fromJson.getUid()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private boolean tempPwdExists4User(final Session session,
      final PwdEntry fromJson) throws Exception {
    return TempPwdUtil.tempPwdExists4User(session, fromJson.getUid(),
        fromJson.getTempPwd());
  }

  private void assignNewPwd(final PwdEntry fromJson, final User fromDB) {
    if (fromJson.getNewPwd() != null) {
      fromDB.setPwd(fromJson.getNewPwd());
    }
  }

  private PwdEntry newIntanceFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return PwdEntry.newInstance(json);
    }
    return null;
  }

  private FullHttpResponse verifyPwdEntry(final PwdEntry fromJson) {
    final ByteArrayDataOutput respBuf = getRespBuf();

    if (fromJson == null) {
      appendln("No user or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(fromJson.getUid())) {
      appendln("No user id specified in PwdEntry", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(fromJson.getTempPwd())) {
      appendln("No temp pwd specified in PwdEntry", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(fromJson.getNewPwd())) {
      appendln("No new pwd specified in PwdEntry", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }
}
