package com.gibbon.peeq.handlers;

import java.io.IOException;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ProfileWebHandler extends AbastractPeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(ProfileWebHandler.class);

  public ProfileWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    PeeqWebHandler pwh = new ProfileFilterWebHandler(getUriParser(),
        getRespBuf(), getHandlerContext(), getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
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

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final Profile retInstance = (Profile) session.get(Profile.class, uid);
      txn.commit();

      /* load from object store */
      loadAvatarFromObjectStore(retInstance);

      /* buffer result */
      return newResponseForInstance(uid, retInstance);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void loadAvatarFromObjectStore(final Profile profile)
      throws Exception {
    if (profile == null) {
      return;
    }

    final byte[] readContent = readAvatarImage(profile);
    if (readContent != null) {
      profile.setAvatarImage(readContent);
    }
  }

  private byte[] readAvatarImage(final Profile profile) throws Exception {
    final ObjectStoreClient osc = new ObjectStoreClient();
    return osc.readAvatarImage(profile.getAvatarUrl());
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

    /* deserialize json */
    final Profile fromJson;
    try {
      fromJson = newProfileFromRequest();
      if (fromJson == null) {
        appendln("No profile or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Transaction txn = null;
    /*
     * query to get DB copy to avoid updating fields (not explicitly set by
     * Json) to NULL
     */
    Profile fromDB = null;
    try {
      txn = getSession().beginTransaction();
      fromDB = (Profile) getSession().get(Profile.class, uid);
      txn.commit();
      if (fromDB == null) {
        appendln(String.format("Nonexistent profile for user ('%s')", uid));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }

    /* use uid from url, ignore that from json */
    fromJson.setUid(uid);
    fromDB.setAsIgnoreNull(fromJson);

    try {
      /* save to object store */
      saveAvatarToObjectStore(fromDB);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    try {
      txn = getSession().beginTransaction();
      getSession().update(fromDB);
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void saveAvatarToObjectStore(final Profile profile) throws Exception {
    final String url = saveAvatarImage(profile);
    if (url != null) {
      profile.setAvatarUrl(url);
    }
  }

  private String saveAvatarImage(final Profile profile) throws Exception {
    ObjectStoreClient osc = new ObjectStoreClient();
    return osc.saveAvatarImage(profile);
  }

  private Profile newProfileFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return Profile.newProfile(json);
    }
    return null;
  }

  private void appendMethodNotAllowed(final String methodName) {
    final String resourceName = getUriParser().getPathStream().getTouchedPath();
    appendln(String.format("Method '%s' not allowed on resource '%s'",
        methodName, resourceName));
  }

  private FullHttpResponse newResponseForInstance(final String id,
      final Profile instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(
          String.format("Nonexistent resource with URI: /profiles/%s", id));
      return newResponse(HttpResponseStatus.NOT_FOUND);
    }
  }
}
