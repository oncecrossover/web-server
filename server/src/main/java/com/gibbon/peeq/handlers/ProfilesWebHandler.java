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
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.ResourceURIParser;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.util.CharsetUtil;

public class ProfilesWebHandler extends AbastractPeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(ProfilesWebHandler.class);

  public ProfilesWebHandler(ResourceURIParser uriParser, StrBuilder respBuf,
      ChannelHandlerContext ctx, FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    PeeqWebHandler pfwh = new ProfileFilterWebHandler(getUriParser(),
        getRespBuf(), getHandlerContext(), getRequest());

    if (pfwh.willFilter()) {
      return pfwh.handle();
    } else {
      return onGet();
    }
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

  private FullHttpResponse onGet() {
    /* get id */
    final String uid = getUriParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      final Profile profile = (Profile) getSession().get(Profile.class, uid);
      txn.commit();

      /* result queried */
      appendResourceln(uid, profile);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      /* rollback */
      txn.rollback();
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private FullHttpResponse onCreate() {
    appendMethodNotAllowed(HttpMethod.POST.name());
    return newResponse(HttpResponseStatus.METHOD_NOT_ALLOWED);
  }

  private FullHttpResponse onDelete() {
    appendMethodNotAllowed(HttpMethod.DELETE.name());
    return newResponse(HttpResponseStatus.METHOD_NOT_ALLOWED);
  }

  private FullHttpResponse onUpdate() {
    /* get id */
    final String uid = getUriParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    final Profile profile;
    try {
      profile = newProfileFromRequest();
      if (profile == null) {
        appendln("No profile or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }

    /* ignore id from json */
    profile.setUid(uid);
    setAvatarUrl(profile);

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      getSession().update(profile);
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      /* rollback */
      txn.rollback();
      /* server error */
      LOG.warn(e.toString());
      appendln(e.toString());
      return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private void setAvatarUrl(final Profile profile) {
    final String avatarUrl = saveAvatarImage(profile);
    if (avatarUrl != null) {
      profile.setAvatarUrl(avatarUrl);
    }
  }

  private String saveAvatarImage(final Profile profile) {
    ObjectStoreClient osc = new ObjectStoreClient();
    try {
      return osc.saveAvatarImage(profile);
    } catch (IOException e) {
      LOG.warn(super.stackTraceToString(e));
    }
    return null;
  }

  private Profile newProfileFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final String json = content.toString(CharsetUtil.UTF_8);
      return Profile.newProfile(json);
    }
    return null;
  }

  private void appendMethodNotAllowed(final String methodName) {
    final String resourceName = getUriParser().getPathStream().getTouchedPath();
    appendln(String.format("Method '%s' not allowed on resource '%s'",
        methodName, resourceName));
  }

  private void appendResourceln(final String resourceId, final Profile profile)
      throws JsonProcessingException {
    if (profile != null) {
      appendln(profile.toJson());
    } else {
      appendln(String.format("Nonexistent resource with URI: /profiles/%s",
          resourceId));
    }
  }
}
