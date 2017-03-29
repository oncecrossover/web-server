package com.snoop.server.web.handlers;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.PcAccount;
import com.snoop.server.db.model.PcEntry;
import com.snoop.server.util.ResourcePathParser;
import com.snoop.server.util.StripeUtil;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.Card;
import com.stripe.model.Customer;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class PcEntryWebHandler extends AbastractWebHandler
    implements WebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(PcEntryWebHandler.class);

  public PcEntryWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final WebHandler pwh = new PcEntryFilterWebHandler(getPathParser(),
        getRespBuf(), getHandlerContext(), getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
  }

  @Override
  protected FullHttpResponse handleDeletion() {
    return onDelete();
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  private FullHttpResponse onCreate() {
    final PcEntry fromJson;
    /* new instance from request */
    try {
      fromJson = newInstanceFromRequest();
      if (fromJson == null) {
        appendln("No PcEntry or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify uid */
    if (StringUtils.isBlank(fromJson.getUid())) {
      appendln("No user id specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* verify token */
    if (StringUtils.isBlank(fromJson.getToken())) {
      appendln("No PcEntry token specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Session session;
    Transaction txn = null;
    PcAccount pcAccount = null;
    try {
      /* query PcAccount */
      session = getSession();
      txn = session.beginTransaction();
      pcAccount = (PcAccount) session.get(PcAccount.class, fromJson.getUid());
      txn.commit();

      /* no PcAccount */
      if (pcAccount == null) {
        appendln(String.format("Nonexistent PcAccount for user ('%s')",
            fromJson.getUid()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Card card = null;
    Customer customer = null;
    try {
      /* retrieve customer */
      final String cusId = pcAccount.getChargeFrom();
      customer = StripeUtil.getCustomer(cusId);
      if (customer == null) {
        appendln(String.format("Nonexistent Customer ('%s') for user ('%s')",
            cusId, fromJson.getUid()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    try {
      /* add card to customer */
      card = StripeUtil.addCardToCustomer(customer, fromJson.getToken());
      if (card == null) {
        appendln(String.format("Failed to add card (%s) for user ('%s')",
            fromJson.getToken(), fromJson.getUid()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    try {
      /* update default card */
      StripeUtil.updateDefaultSource(customer, card);
    } catch (Exception e) {
      try {
        /* delete card */
        StripeUtil.deleteCard(card);
      } catch (StripeException se) {
        stashServerError(se, LOG);
      }
      return newServerErrorResponse(e, LOG);
    }

    try {
      /* Persist new PcEntry */
      session = getSession();
      txn = session.beginTransaction();
      fromJson.setEntryId(card.getId())
              .setBrand(card.getBrand())
              .setLast4(card.getLast4());
      session.save(fromJson);
      txn.commit();
      appendln(toIdJson("id", fromJson.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      try {
        /* delete card */
        StripeUtil.deleteCard(card);
      } catch (StripeException se) {
        stashServerError(se, LOG);
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private PcEntry newInstanceFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return PcEntry.newInstance(json);
    }
    return null;
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    Session session = null;
    try {
      session = getSession();
      txn = session.beginTransaction();
      final PcEntry retInstance = (PcEntry) session.get(PcEntry.class,
          Long.parseLong(id));
      txn.commit();

      /* buffer result */
      return newResponseForInstance(id, retInstance);
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  private FullHttpResponse newResponseForInstance(final String id,
      final PcEntry instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(
          String.format("Nonexistent resource with URI: /pcentries/%s", id));
      return newResponse(HttpResponseStatus.NOT_FOUND);
    }
  }

  private FullHttpResponse onDelete() {
    /* get id */
    final String id = getPathParser().getPathStream().nextToken();

    /* verify id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Session session;
    Transaction txn = null;
    PcEntry pcEntry = null;
    try {
      /* query PcEntry */
      session = getSession();
      txn = session.beginTransaction();
      pcEntry = (PcEntry) session.get(PcEntry.class, Long.parseLong(id));
      txn.commit();

      /* no PcEntry */
      if (pcEntry == null) {
        appendln(String.format("Nonexistent PcEntry ('%s')", id));
        return newResponse(HttpResponseStatus.NO_CONTENT);
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    PcAccount pcAccount = null;
    try {
      /* query PcAccount */
      session = getSession();
      txn = session.beginTransaction();
      pcAccount = (PcAccount) session.get(PcAccount.class, pcEntry.getUid());
      txn.commit();

      /* no PcAccount */
      if (pcAccount == null) {
        appendln(String.format("Nonexistent PcAccount for user ('%s')",
            pcEntry.getUid()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    Customer customer = null;
    try {
      /* retrieve customer */
      final String cusId = pcAccount.getChargeFrom();
      customer = StripeUtil.getCustomer(cusId);
      if (customer == null) {
        appendln(String.format("Nonexistent Customer ('%s') for user ('%s')",
            cusId, pcEntry.getUid()));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    try {
      /* delete PcEntry */
      session = getSession();
      txn = session.beginTransaction();
      session.delete(pcEntry);

      /* delete card */
      StripeUtil.deleteCard(customer, pcEntry.getEntryId());

      /* commit DB delete */
      txn.commit();
      appendln(String.format("Deleted resource with URI: /pcentries/%d",
          pcEntry.getId()));
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (HibernateException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (StripeException e) {
      if (txn != null && txn.isActive()) {
        txn.rollback();
      }
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }
}
