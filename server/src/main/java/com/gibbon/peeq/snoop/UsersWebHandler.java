package com.gibbon.peeq.snoop;

import static io.netty.handler.codec.http.HttpVersion.HTTP_1_1;

import java.io.IOException;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.User;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpHeaderNames;
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
    return onGetUser();
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreateUser();
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdUser();
  }

  @Override
  protected FullHttpResponse handleDeletion() {
    return onDelUser();
  }

  private FullHttpResponse onCreateUser() {
    final User user;
    try {
      user = newUserFromRequest();
      if (user == null) {
        appendln("No user or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }

    try {
      getSession().beginTransaction();
      getSession().save(user);
      getSession().getTransaction().commit();
      appendln(String.format("New resource created with URI: /users/%s",
          user.getUid()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (Exception e) {
      /* rollback */
      getSession().getTransaction().rollback();
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private String getPath(int index) {
    String path = "";
    final PathStream ps = getUriParser().getPathStream();
    for (int i = 0; i <= index && ps.hasNext(); i++) {
      path = ps.next();
    }
    return path;
  }

  private FullHttpResponse onGetUser() {
    /* get user id */
    final String uid = getPath(1);

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    try {
      getSession().beginTransaction();
      final User user = (User) getSession().get(User.class, uid);
      getSession().getTransaction().commit();

      /* user queried */
      appendUser(uid, user);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      /* rollback */
      getSession().getTransaction().rollback();
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private void appendUser(final String uid, final User user)
      throws JsonProcessingException {
    if (user != null) {
      appendln(user.toJson());
    } else {
      appendln(String.format("Nonexistent resource with URI: /users/%s", uid));
    }
  }

  private void appendln(final String str) {
    getRespBuf().appendln(str);
  }

  private void clearBuf() {
    getRespBuf().clear();
  }

  private FullHttpResponse newResponse(HttpResponseStatus status) {
    FullHttpResponse response = new DefaultFullHttpResponse(HTTP_1_1, status,
        Unpooled.copiedBuffer(getRespBuf().toString(), CharsetUtil.UTF_8));
    getRespBuf().clear();

    response.headers().set(HttpHeaderNames.CONTENT_TYPE,
        "application/json; charset=UTF-8");
    return response;
  }

  private FullHttpResponse onDelUser() {
    /* get user id */
    final String uid = getPath(1);

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    final User user = new User();
    user.setUid(uid);
    try {
      getSession().beginTransaction();
      getSession().delete(user);
      getSession().getTransaction().commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      /* rollback */
      getSession().getTransaction().rollback();
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private FullHttpResponse onUpdUser() {
    final User user;
    try {
      user = newUserFromRequest();
      if (user == null) {
        appendln("No user or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }

    try {
      getSession().beginTransaction();
      getSession().update(user);
      getSession().getTransaction().commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      /* rollback */
      getSession().getTransaction().rollback();
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
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
