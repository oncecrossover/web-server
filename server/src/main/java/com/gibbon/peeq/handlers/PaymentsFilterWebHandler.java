package com.gibbon.peeq.handlers;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gibbon.peeq.db.model.Payment;
import com.gibbon.peeq.util.FilterParamParser;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.base.Joiner;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class PaymentsFilterWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(PaymentsFilterWebHandler.class);

  public PaymentsFilterWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request,
        new FilterParamParser(request.uri()));
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onQuery();
  }

  private FullHttpResponse onQuery() {
    Transaction txn = null;
    try {
      final Session session = getSession();
      txn = session.beginTransaction();
      String resultJson = getResultJson(session);
      txn.commit();

      /* result queried */
      appendln(resultJson);
      return newResponse(HttpResponseStatus.OK);
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }

  String getResultJson(final Session session) throws JsonProcessingException {
    final StrBuilder sb = new StrBuilder();
    final Criteria criteria = session.createCriteria(Payment.class);
    criteria.addOrder(Order.desc("createdTime"));

    final Map<String, String> kvs = getFilterParamParser().getQueryKVs();
    List<Payment> payments = null;

    /* no query condition specified */
    if (kvs.entrySet().size() == 0) {
      return "";
    } else if (kvs.containsKey(FilterParamParser.SB_STAR)) {
      /* select * from xxx */
      payments = criteria.list();
    } else {
      for (Map.Entry<String, String> kv : kvs.entrySet()) {
        if (kv.getKey() != FilterParamParser.SB_STAR) {
          criteria.add(Restrictions.eq(kv.getKey(), kv.getValue()));
        }
      }
      payments = criteria.list();
    }

    sb.append("[");
    sb.append(Joiner.on(",").skipNulls().join(payments));
    sb.append("]");
    return sb.toString();
  }
}
