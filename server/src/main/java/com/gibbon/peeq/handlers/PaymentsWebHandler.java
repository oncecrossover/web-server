package com.gibbon.peeq.handlers;

import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.Transaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.gibbon.peeq.db.model.Payment;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;
import com.stripe.Stripe;
import com.stripe.exception.APIConnectionException;
import com.stripe.exception.APIException;
import com.stripe.exception.AuthenticationException;
import com.stripe.exception.CardException;
import com.stripe.exception.InvalidRequestException;
import com.stripe.exception.StripeException;
import com.stripe.model.Customer;

public class PaymentsWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(PaymentsWebHandler.class);

  static {
    Stripe.apiKey = "sk_test_qHGH10BjT9f7jSze3mhHijuU";
  }

  public PaymentsWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    final PeeqWebHandler pwh = new PaymentsFilterWebHandler(getUriParser(),
        getRespBuf(), getHandlerContext(), getRequest());

    if (pwh.willFilter()) {
      return pwh.handle();
    } else {
      return onGet();
    }
  }

  private FullHttpResponse onGet() {
    /* get id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: id");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      final Payment payment = (Payment) getSession().get(Payment.class,
          Long.parseLong(id));
      txn.commit();

      /* buffer result */
      appendPayment(id, payment);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void appendPayment(final String id, final Payment payment)
      throws JsonProcessingException {
    if (payment != null) {
      appendByteArray(payment.toJsonByteArray());
    } else {
      appendln(String.format("Nonexistent resource with URI: /payments/%s", id));
    }
  }

  @Override
  protected FullHttpResponse handleCreation() {
    return onCreate();
  }

  private FullHttpResponse onCreate() {
    final Payment fromJson;
    try {
      /* instantiate new instance of Payment */
      fromJson = newPaymentFromRequest();
      if (fromJson == null) {
        appendln("No payment or incorrect format specified.");
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* verify token */
    if (StringUtils.isBlank(fromJson.getToken())) {
      appendln("No payment token specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* set time */
    final Date now = new Date();
    fromJson.setCreatedTime(now);

    Customer customer = null;
    Transaction txn = null;
    try {
      /* create customer */
      customer = createStripeCustomer(fromJson);
      if (customer == null) {
        appendln("Creating payment account failed.");
        return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
      }
      /* save customer id */
      fromJson.setAccId(customer.getId());

      /* create payment */
      txn = getSession().beginTransaction();
      getSession().save(fromJson);
      txn.commit();
      appendln(String.format("New resource created with URI: /payments/%s",
          fromJson.getId()));
      return newResponse(HttpResponseStatus.CREATED);
    } catch(StripeException e) {
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      try {
        deleteStripeCustomer(customer);
      } catch (StripeException se) {
        stashServerError(se, LOG);
      }
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  private void deleteStripeCustomer(final Customer customer)
      throws AuthenticationException, InvalidRequestException,
      APIConnectionException, CardException, APIException {
    customer.delete();
  }

  private Customer createStripeCustomer(final Payment payment)
      throws StripeException {
    final Map<String, Object> customerParams = new HashMap<String, Object>();
    /* {uid | type | lastFour} */
    customerParams.put("description", String.format("customer@{%s | %s | %s}",
        payment.getUid(), payment.getType(), payment.getLastFour()));
    customerParams.put("source", payment.getToken());

    return Customer.create(customerParams);
  }

  private Payment newPaymentFromRequest()
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return Payment.newPayment(json);
    }
    return null;
  }

  @Override
  protected FullHttpResponse handleDeletion() {
    return onDelete();
  }

  private FullHttpResponse onDelete() {
    /* get id */
    final String id = getUriParser().getPathStream().nextToken();

    /* no id */
    if (StringUtils.isBlank(id)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    Transaction txn = null;
    try {
      txn = getSession().beginTransaction();
      final Payment payment = (Payment) getSession().get(Payment.class,
          Long.parseLong(id));
      if (payment != null) {
        getSession().delete(payment);
      }
      txn.commit();
      return newResponse(HttpResponseStatus.NO_CONTENT);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }
}
