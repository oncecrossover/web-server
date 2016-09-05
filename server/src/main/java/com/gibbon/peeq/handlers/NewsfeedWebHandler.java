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
import com.gibbon.peeq.util.ResourcePathParser;
import com.google.common.base.Joiner;
import com.google.common.io.ByteArrayDataOutput;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class NewsfeedWebHandler extends AbastractPeeqWebHandler
    implements PeeqWebHandler {

  public NewsfeedWebHandler(ResourcePathParser pathParser,
      ByteArrayDataOutput respBuf, ChannelHandlerContext ctx,
      FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return forward();
  }

  private FullHttpResponse forward() {
    final PeeqWebHandler pwh = new NewsfeedFilterWebHandler(
        getPathParser(),
        getRespBuf(),
        getHandlerContext(),
        getRequest());
    return pwh.handle();
  }
}
