package com.gibbon.peeq.handlers;

import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.transform.Transformers;
import org.hibernate.type.DoubleType;
import org.hibernate.type.LongType;
import org.hibernate.type.StringType;
import org.hibernate.type.TimestampType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.gibbon.peeq.db.model.Quanda;
import com.gibbon.peeq.util.ResourceURIParser;
import com.google.common.base.Joiner;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class NewsfeedWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(NewsfeedWebHandler.class);

  public NewsfeedWebHandler(ResourceURIParser uriParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(uriParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onGet();
  }

  private FullHttpResponse onGet() {
    /* get uid */
    final String uid = getUriParser().getPathStream().nextToken();

    /* no uid */
    if (StringUtils.isBlank(uid)) {
      appendln("Missing parameter: uid");
      return newResponse(HttpResponseStatus.BAD_REQUEST);
    }

    /* build sql */
    final String sql = getSql(uid);

    Session session = null;
    Transaction txn = null;
    try {
      session = getSession();
      txn = session.beginTransaction();

      /* build query */
      final SQLQuery query = session.createSQLQuery(sql);
      query.setResultTransformer(Transformers.aliasToBean(Quanda.class));
      /* add column mapping */
      query.addScalar("id", new LongType())
           .addScalar("asker", new StringType())
           .addScalar("question", new StringType())
           .addScalar("responder", new StringType())
           .addScalar("rate", new DoubleType())
           .addScalar("status", new StringType())
           .addScalar("createdTime", new TimestampType())
           .addScalar("updatedTime", new TimestampType())
           .addScalar("snoops", new LongType());
      final List<Quanda> list = query.list();

      txn.commit();

      /* build json */
      final StrBuilder sb = new StrBuilder();
      sb.append("[");
      sb.append(Joiner.on(",").skipNulls().join(list));
      sb.append("]");

      /* buffer result */
      appendln(sb.toString());
      return newResponse(HttpResponseStatus.OK);
    } catch (HibernateException e) {
      txn.rollback();
      return newServerErrorResponse(e, LOG);
    } catch (Exception e) {
      return newServerErrorResponse(e, LOG);
    }
  }

  /*
   * SELECT QQ.*, COUNT(*) snoops FROM (SELECT Q.id, Q.asker, Q.question,
   * Q.responder, Q.rate, Q.status, Q.createdTime, Q.updatedTime FROM Quanda Q
   * WHERE Q.asker != 'yunxuan' AND Q.responder != 'yunxuan' AND Q.status =
   * 'ANSWERED' AND NOT EXISTS (SELECT DISTINCT S.quandaId FROM Snoop S WHERE
   * S.uid = 'yunxuan' AND Q.id = S.quandaId)) QQ LEFT JOIN Snoop S ON QQ.id =
   * S.quandaId GROUP BY QQ.id ORDER BY QQ.updatedTime DESC;
   */
  private String getSql(final String uid) {
    final StrBuilder sb = new StrBuilder();
    sb.appendln("SELECT QQ.*, COUNT(S.quandaId) snoops FROM");
    sb.appendln("(SELECT Q.id, Q.asker, Q.question, Q.responder,");
    sb.appendln("Q.rate, Q.status, Q.createdTime, Q.updatedTime");
    sb.appendln("FROM Quanda Q WHERE Q.asker != '%s'");
    sb.appendln("AND  Q.responder != '%s'");
    sb.appendln("AND  Q.status = 'ANSWERED'");
    sb.appendln("AND NOT EXISTS (");
    sb.appendln("SELECT DISTINCT S.quandaId FROM Snoop S");
    sb.appendln("WHERE S.uid = '%s'");
    sb.appendln("AND Q.id = S.quandaId)) QQ");
    sb.appendln("LEFT JOIN Snoop S ON QQ.id = S.quandaId");
    sb.appendln("GROUP BY QQ.id");
    sb.appendln("ORDER BY QQ.updatedTime DESC");

    return String.format(sb.toString(), uid, uid, uid);
  }
}
