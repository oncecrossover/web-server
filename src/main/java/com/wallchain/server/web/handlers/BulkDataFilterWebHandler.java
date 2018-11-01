package com.wallchain.server.web.handlers;

import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.common.collect.Lists;
import com.google.common.io.ByteArrayDataOutput;
import com.wallchain.server.model.BulkData;
import com.wallchain.server.util.ObjectStoreClient;
import com.wallchain.server.util.ResourcePathParser;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpResponseStatus;

public class BulkDataFilterWebHandler extends AbastractWebHandler
    implements WebHandler {

  protected static final Logger LOG = LoggerFactory
      .getLogger(BulkDataFilterWebHandler.class);

  public BulkDataFilterWebHandler(
      final ResourcePathParser pathParser,
      final ByteArrayDataOutput respBuf,
      final ChannelHandlerContext ctx,
      final FullHttpRequest request) {
    super(pathParser, respBuf, ctx, request);
  }

  @Override
  protected FullHttpResponse handleRetrieval() {
    return onQuery();
  }

  private FullHttpResponse onQuery() {
    /* get uri */
    final String uriKey = "uri";
    final Map<String, List<String>> params = getQueryParser().params();
    final List<String> uris = params.containsKey(uriKey) ? params.get(uriKey)
        : Lists.newArrayList();

    /* read from object store */
    final ObjectStoreClient osc = new ObjectStoreClient();
    final BulkData bulkData = new BulkData();
    for (String uri : uris) {
      if (StringUtils.isBlank(uri)) {
        continue;
      }

      byte[] bytes = null;
      try {
        bytes = osc.readFromStore(uri);
      } catch (Exception e) {
        return newServerErrorResponse(e, LOG);
      }

      if (bytes != null) {
        bulkData.add(uri, bytes);
      }
    }

    /* return */
    try {
      appendByteArray(bulkData.toJsonByteArray());
    } catch (JsonProcessingException e) {
      stashServerError(e, LOG);
      return newServerErrorResponse(e, LOG);
    }
    return newResponse(HttpResponseStatus.OK);
  }
}
