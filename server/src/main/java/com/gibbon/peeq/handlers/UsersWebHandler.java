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
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.util.ResourceURIParser;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.util.CharsetUtil;

public class UsersWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(UsersWebHandler.class);

  public UsersWebHandler(ResourceURIParser uriParser, StrBuilder respBuf,
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

  @Override
  protected FullHttpResponse handleDeletion() {
    return onDelete();
  }

  private FullHttpResponse onCreate() {
    final User user;
    try {
      user = newUserFromRequest();
      if (user == null) {
        appendln("No user or incorrect format specified.");
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
      getSession().save(user);
      txn.commit();
      appendln(String.format("New resource created with URI: /users/%s",
          user.getUid()));
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

  private FullHttpResponse onGet() {
    /* get user id */
    final String uid = getUriParser().getPathStream().getPath(1);

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      final User user = (User) getSession().get(User.class, uid);
      txn.commit();

      /* user queried */
      appendUserln(uid, user);
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

  private void appendUserln(final String uid, final User user)
      throws JsonProcessingException {
    if (user != null) {
      appendln(user.toJson());
    } else {
      appendln(String.format("Nonexistent resource with URI: /users/%s", uid));
    }
  }

  private FullHttpResponse onDelete() {
    /* get user id */
    final String uid = getUriParser().getPathStream().getPath(1);

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    final User user = new User();
    user.setUid(uid);
    /* assign uid for profile so that Hibernate can do cascade delete */
    user.setProfile(new Profile().setUid(user.getUid()));

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      getSession().delete(user);
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

  private FullHttpResponse onUpdate() {
    final User user;
    try {
      user = newUserFromRequest();
      if (user == null) {
        appendln("No user or incorrect format specified.");
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
     * assign uid for profile to explicitly tell Hibernate to update profile
     * insteading of inserting
     */
    user.getProfile().setUid(user.getUid());

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      getSession().update(user);
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

  private User newUserFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final String userJson = content.toString(CharsetUtil.UTF_8);
      return User.newUser(userJson);
    }
    return null;
  }
}
