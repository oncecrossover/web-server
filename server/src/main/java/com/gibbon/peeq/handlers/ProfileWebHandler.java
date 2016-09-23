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
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ProfileWebHandler extends AbastractPeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(ProfileWebHandler.class);

  public ProfileWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return forward();
  }

  private FullHttpResponse forward() {
    PeeqWebHandler pwh = new ProfileFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());
    return pwh.handle();
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private byte[] readAvatarImage(final Profile profile) throws Exception {
    final ObjectStoreClient osc = new ObjectStoreClient();
    return osc.readAvatarImage(profile.getAvatarUrl());
  }

  private FullHttpResponse onUpdate() {
    /* get id */
    final String uid = getPathParser().getPathStream().nextToken();

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
    Session session = null;
    /*
     * query to get DB copy to avoid updating fields (not explicitly set by
     * Json) to NULL
     */
    Profile fromDB = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      fromDB = (Profile) session.get(Profile.class, uid);
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
      session = getSession();
      txn = session.beginTransaction();
      session.update(fromDB);
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
    final String resourceName = getPathParser().getPathStream().getTouchedPath();
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
