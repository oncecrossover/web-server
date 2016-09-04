package com.gibbon.peeq.handlers;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.hibernate.transform.Transformers;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.Profile;
import com.gibbon.peeq.util.FilterParamParser;
import com.gibbon.peeq.util.ObjectStoreClient;
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class ProfileFilterWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {
  protected static final Logger LOG = LoggerFactory
      .getLogger(ProfileFilterWebHandler.class);

  public ProfileFilterWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request,
        new FilterParamParser(request.uri()));
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onQuery();
  }

  private void loadAvatarsFromObjectStore(List<Profile> profiles)
      throws Exception {
    for (Profile profile : profiles) {
      if (StringUtils.isBlank(profile.getAvatarUrl())) {
        continue;
      }

      final ObjectStoreClient osc = new ObjectStoreClient();
      final byte[] readContent = osc.readAvatarImage(profile.getAvatarUrl());
      if (readContent != null) {
        profile.setAvatarImage(readContent);
      }
    }
  }

  private String getResultJson(final Session session) throws Exception {
    StrBuilder sb = new StrBuilder();
    Criteria criteria = session.createCriteria(Profile.class);
    criteria.addOrder(Order.desc("updatedTime"));
    criteria.addOrder(Order.desc("createdTime"));
    criteria.setProjection(
        Projections.projectionList()
          .add(Projections.property("uid"), "uid")
          .add(Projections.property("rate"), "rate")
          .add(Projections.property("avatarUrl"), "avatarUrl")
          .add(Projections.property("fullName"), "fullName")
          .add(Projections.property("title"), "title")
          .add(Projections.property("aboutMe"), "aboutMe"))
    .setResultTransformer(Transformers.aliasToBean(Profile.class));

    Map<String, String> kvs = getFilterParamParser().getQueryKVs();
    List<Profile> list = null;

    /* no query condition specified */
    if (kvs.entrySet().size() == 0) {
      return "";
    } else if (kvs.containsKey(FilterParamParser.SB_STAR)) {
      /* select * from xxx */
      list = criteria.list();
    } else {
      for (Map.Entry<String, String> kv : kvs.entrySet()) {
        if (kv.getKey() != FilterParamParser.SB_STAR) {
          /* Edmund --> %Edmund% */
          String pattern = String.format("%%%s%%", kv.getValue());
          criteria.add(Restrictions.like(kv.getKey(), pattern));
        }
      }
      list = criteria.list();
    }

    loadAvatarsFromObjectStore(list);

    return listToJsonString(list);
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
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    }
  }
}
