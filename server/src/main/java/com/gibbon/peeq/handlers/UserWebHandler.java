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
import com.gibbon.peeq.db.util.UserDBUtil;
import com.gibbon.peeq.util.ResourcePathParser;
import com.gibbon.peeq.util.StripeUtil;
import com.gibbon.peeq.util.UserUtil;
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

  public UserWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }


  static FullHttpResponse verifyUser(final User user,
      final ByteArrayDataOutput respBuf) {

    if (user == null) {
      appendln("No user or incorrect format specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(user.getUid())) {
      appendln("No uid specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(user.getPwd())) {
      appendln("No password specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    if (StringUtils.isBlank(user.getFullName())) {
      appendln("No full name specified.", respBuf);
      return newResponse(HttpResponseStatus.BAD_REQUEST, respBuf);
    }

    return null;
  }


  private FullHttpResponse onCreate() {
    final User fromJson;
    try {
      fromJson = newUserFromRequest();
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify */
    final FullHttpResponse resp = verifyUser(fromJson, getRespBuf());
    if ( resp != null) {
      return resp;
    }

    /* set fullName to profile, user table doesn't store fullName */
    fromJson.getProfile().setFullName(fromJson.getFullName());

    Transaction txn = null;
    Customer customer = null;
    Session session = null;
    try {
      /* create Stripe customer */
      customer = StripeUtil.createCustomerForUser(fromJson.getUid());
      if (customer == null) {
        appendln(String.format("Creating Customer for user '%s' failed.",
            fromJson.getUid()));
        return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
      }

      /* save customer id */
      fromJson.getPcAccount().setChargeFrom(customer.getId());

      session = getSession();
      txn = session.beginTransaction();

      /* encrypt */
      UserUtil.encryptPwd(fromJson);

      /* save */
      session.save(fromJson);

      /* commit transaction */
      txn.commit();
      appendln(toIdJson("uid", fromJson.getUid()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (StripeException e) {
      return newServerErrorResponse(e, LOG);
    } catch (HibernateException e) {
      txn.rollback();
      try {
        StripeUtil.deleteCustomer(customer);
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
    final String uid = getPathParser().getPathStream().nextToken();

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
      final User retInstance = UserDBUtil.getUser(session, uid, false);
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
