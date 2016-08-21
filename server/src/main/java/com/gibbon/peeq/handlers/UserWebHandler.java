package com.gibbon.peeq.handlers;

import java.io.IOException;
import org.apache.commons.lang3.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.User;
import com.gibbon.peeq.util.ResourceURIParser;
import com.gibbon.peeq.util.StripeUtils;
import com.google.common.io.ByteArrayDataOutput;
import com.stripe.exception.StripeException;
import com.stripe.model.Customer;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class UserWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(UserWebHandler.class);

  public UserWebHandler(ResourceURIParser uriParser,
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

  private FullHttpResponse onCreate() {
    final User fromJson;
    try {
      fromJson = newUserFromRequest();
      if (fromJson == null) {
        appendln("No user or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* set fullName to profile, user table doesn't store fullName */
    fromJson.getProfile().setFullName(fromJson.getFullName());

    Transaction txn = null;
    Customer customer = null;
    Session session = null;
    try {
      /* create Stripe customer */
      customer = StripeUtils.createCustomerForUser(fromJson.getUid());
      if (customer == null) {
        appendln(String.format("Creating Customer for user '%s' failed.",
            fromJson.getUid()));
        return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
      }

      /* save customer id */
      fromJson.getPcAccount().setChargeFrom(customer.getId());

      session = getSession();
      txn = session.beginTransaction();
      session.save(fromJson);
      txn.commit();
      appendln(toIdJson("uid", fromJson.getUid()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (StripeException e) {
      return newServerErrorResponse(e, LOG);
    } catch (HibernateException e) {
      txn.rollback();
      try {
        StripeUtils.deleteCustomer(customer);
      } catch (StripeException se) {
        stashServerError(se, LOG);
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
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

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final User retInstance = (User) session.get(User.class, uid);
      txn.commit();

      /* buffer result */
      return newResponseForInstance(uid, retInstance);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse newResponseForInstance(final String uid,
      final User instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(String.format("Nonexistent resource with URI: /users/%s", uid));
      return newResponse(HttpResponseStatus.NOT_FOUND);
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

    /* deserialize json */
    final User fromJson;
    try {
      fromJson = newUserFromRequest();
      if (fromJson == null) {
        appendln("No user or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Transaction txn = null;
    Session sesion = null;
    /*
     * query to get DB copy to avoid updating fields (not explicitly set by
     * Json) to NULL
     */
    User fromDB = null;
    try {
      sesion = getSession();
      txn = sesion.beginTransaction();
      fromDB = (User) getSession().get(User.class, uid);
      txn.commit();
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }

    /* use uid from url, ignore that from json */
    fromJson.setUid(uid);
    if (fromDB != null) {
      fromDB.setAsIgnoreNull(fromJson);
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

  private User newUserFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return User.newInstance(json);
    }
    return null;
  }
}
