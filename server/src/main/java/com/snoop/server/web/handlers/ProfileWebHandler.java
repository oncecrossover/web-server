package com.snoop.server.web.handlers;

import java.io.IOException;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.Profile;
import com.snoop.server.util.ObjectStoreClient;
import com.snoop.server.util.ResourcePathParser;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ProfileWebHandler extends AbastractWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(ProfileWebHandler.class);

  public ProfileWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new ProfileFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
  }

  private FullHttpResponse onGet() {
    /* get id */
    Long id = null;
    try {
      id = Long.parseLong(getPathParser().getPathStream().nextToken());
    } catch (NumberFormatException e) {
      appendln("Incorrect id format.");
      return newClientErrorResponse(e, LOG);
    }

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final Profile retInstance = (Profile) session.get(Profile.class, id);
      txn.commit();

      /* buffer result */
      return newResponseForInstance(id.toString(), retInstance);
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }
  }

  @Override
  protected FullHttpResponse handleUpdate() {
    return onUpdate();
  }

  private FullHttpResponse onUpdate() {
    /* get id */
    Long id = null;
    try {
      id = Long.parseLong(getPathParser().getPathStream().nextToken());
    } catch (NumberFormatException e) {
      appendln("Incorrect id format.");
      return newClientErrorResponse(e, LOG);
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
    /**
     * query to get DB copy to avoid updating fields (e.g. not explicitly set by
     * Json) to NULL
     */
    Profile fromDB = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      fromDB = (Profile) session.get(Profile.class, id);
      txn.commit();
      if (fromDB == null) {
        appendln(String.format("Nonexistent profile for user ('%d')", id));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    }

    /* use id from url, ignore that from json */
    fromJson.setId(id);
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
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
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
      return Profile.newInstance(json);
    }
    return null;
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
