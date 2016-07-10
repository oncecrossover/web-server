package com.gibbon.peeq.handlers;

import java.io.IOException;
import org.apache.commons.lang3.StringUtils;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.util.CharsetUtil;

public class UsersWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(UsersWebHandler.class);

  public UsersWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
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
      return newServerErrorResponse(e, LOG);
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
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse onGet() {
    /* get user id */
    final String uid = getUriParser().getPathStream().nextToken();

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
      appendUser(uid, user);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void appendUser(final String uid, final User user)
      throws JsonProcessingException {
    if (user != null) {
      appendByteArray(user.toJsonByteArray());
    } else {
      appendln(String.format("Nonexistent resource with URI: /users/%s", uid));
    }
  }

  private FullHttpResponse onDelete() {
    /* get user id */
    final String uid = getUriParser().getPathStream().nextToken();

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
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse onUpdate() {
    /* get user id */
    final String uid = getUriParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    final User user;
    try {
      user = newUserFromRequest();
      if (user == null) {
        appendln("No user or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /*
     * assign uid for profile to explicitly tell Hibernate to update profile
     * insteading of inserting
     */
    user.setUid(uid);
    user.getProfile().setUid(user.getUid());

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      getSession().update(user);
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private User newUserFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return User.newUser(json);
    }
    return null;
  }
}
