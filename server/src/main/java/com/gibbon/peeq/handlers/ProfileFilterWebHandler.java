package com.gibbon.peeq.handlers;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Restrictions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.util.FilterParameterParser;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.base.Joiner;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ProfileFilterWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  private FilterParameterParser paramParser;

  public ProfileFilterWebHandler(ResourceURIParser uriParser,
      StrBuilder respBuf, ChannelHandlerContext ctx, FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
    paramParser = new FilterParameterParser(request.uri());
  }

  protected static final Logger LOG = LoggerFactory
      .getLogger(UsersWebHandler.class);

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onQuery();
  }

  @Override
  public Boolean willFilter() {
    return paramParser.paramCount() > 0 && paramParser.cotnainsKey("filter");
  }

  String getResultJson(final Session session) throws JsonProcessingException {
    StrBuilder sb = new StrBuilder();
    Criteria criteria = session.createCriteria(Profile.class);

    Map<String, String> kvs = paramParser.getQueryKVs();
    List<Profile> profiles = null;

    /* no query condition specified */
    if (kvs.entrySet().size() == 0) {
      return "";
    } else if (kvs.containsKey(FilterParameterParser.SB_STAR)) {
      /* select * from xxx */
      profiles = criteria.list();
    } else {
      for (Map.Entry<String, String> kv : kvs.entrySet()) {
        if (kv.getKey() != FilterParameterParser.SB_STAR) {
          criteria.add(Restrictions.eq(kv.getKey(), kv.getValue()));
        }
      }
      profiles = criteria.list();
    }

    if (profiles.size() > 1) {
      sb.append("[");
    }
    sb.append(Joiner.on(",").skipNulls().join(profiles));
    if (profiles.size() > 1) {
      sb.append("]");
    }
    return sb.toString();
  }

  private FullHttpResponse onQuery() {
    Transaction txn = null;
    try {
      Session session = getSession();
      txn = session.beginTransaction();
      String resultJson = getResultJson(session);
      txn.commit();

      /* result queried */
      appendln(resultJson);
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
}
