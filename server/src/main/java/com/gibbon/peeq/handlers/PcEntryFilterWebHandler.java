package com.gibbon.peeq.handlers;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gibbon.peeq.db.model.PcAccount;
import com.gibbon.peeq.db.model.PcEntry;
import com.gibbon.peeq.util.FilterParamParser;
import com.gibbon.peeq.util.ResourcePathParser;
import com.gibbon.peeq.util.StripeUtil;
import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.io.ByteArrayDataOutput;
import com.stripe.model.Customer;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.text.StrBuilder;
import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PcEntryFilterWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  private static final Logger LOG = LoggerFactory
      .getLogger(PcEntryFilterWebHandler.class);

  public PcEntryFilterWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request,
        new FilterParamParser(request.uri()));
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onQuery();
  }

  private FullHttpResponse onQuery() {
    List<PcEntry> resultList = Lists.newArrayList();
    String uid = "";
    final StrBuilder sbUid = new StrBuilder();

    Transaction txn = null;
    Session session = null;
    try {
      /* query PcEntry as list */
      session = getSession();
      txn = session.beginTransaction();
      resultList = filterAsList(session, sbUid);
      txn.commit();
    } catch (Exception e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }

    /* extract uid */
    uid = sbUid.toString();

    /* verify uid */
    if (StringUtils.isBlank(uid)) {
      appendln("No user id specified.");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    PcAccount pcAccount = null;
    try {
      /* query PcAccount */
      session = getSession();
      txn = session.beginTransaction();
      pcAccount = (PcAccount) session.get(PcAccount.class, uid);
      txn.commit();

      /* no PcAccount */
      if (pcAccount == null) {
        appendln(String.format("Nonexistent PcAccount for user ('%s')", uid));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (HibernateException e) {
      txn.rollback();
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
            cusId, uid));
        return newResponse(HttpResponseStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }

    /* set default source */
    final String defaultSource = customer.getDefaultSource();
    for (PcEntry pce : resultList) {
      if (pce.getEntryId().equals(defaultSource)) {
        pce.setDefault(true);
        break;
      }
    }

    /* build result json */
    final StrBuilder sb = new StrBuilder();
    sb.append("[");
    sb.append(Joiner.on(",").skipNulls().join(resultList));
    sb.append("]");
    appendln(sb.toString());

    /* return result json */
    return newResponse(HttpResponseStatus.OK);
  }

  List<PcEntry> filterAsList(final Session session, final StrBuilder sbUid)
      throws JsonProcessingException {
    final Criteria criteria = session.createCriteria(PcEntry.class);
    criteria.addOrder(Order.desc("createdTime"));

    final Map<String, String> kvs = getFilterParamParser().getQueryKVs();
    List<PcEntry> pcEntries = Lists.newArrayList();

    if (kvs.entrySet().size() == 0) {
      /* no query condition specified */
      return pcEntries;
    } else if (kvs.containsKey(FilterParamParser.SB_STAR)) {
      /* select * from xxx */
      pcEntries = criteria.list();
      return pcEntries;
    } else {
      for (Map.Entry<String, String> kv : kvs.entrySet()) {
        /* stash user id */
        sbUid.clear();
        if (kv.getKey().equals("uid")) {
          sbUid.append(kv.getValue());
        }

        if (kv.getKey() != FilterParamParser.SB_STAR) {
          criteria.add(Restrictions.eq(kv.getKey(), kv.getValue()));
        }
      }
      pcEntries = criteria.list();
    }
    return pcEntries;
  }
}