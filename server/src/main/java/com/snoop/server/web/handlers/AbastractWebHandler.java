package com.snoop.server.web.handlers;

import static io.netty.handler.codec.http.HttpMethod.DELETE;
import static io.netty.handler.codec.http.HttpMethod.GET;
import static io.netty.handler.codec.http.HttpMethod.POST;
import static io.netty.handler.codec.http.HttpMethod.PUT;
import static io.netty.handler.codec.http.HttpVersion.HTTP_1_1;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.StrBuilder;
import org.hibernate.Session;
import org.slf4j.Logger;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.common.base.Joiner;
import com.google.common.io.ByteArrayDataOutput;
import com.snoop.server.db.model.ModelBase;
import com.snoop.server.db.util.HibernateUtil;
import com.snoop.server.util.FilterParamParser;
import com.snoop.server.util.QueryParamsParser;
import com.snoop.server.util.ResourcePathParser;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufUtil;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.DefaultFullHttpResponse;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpHeaderNames;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.netty.util.CharsetUtil;

public abstract class AbastractWebHandler implements WebHandler {
  private ResourcePathParser pathParser;
  private QueryParamsParser queryParser;
  private ByteArrayDataOutput respBuf;
  private ChannelHandlerContext ctx;
  private FullHttpRequest request;
  private FilterParamParser filterParamParser;

  public AbastractWebHandler(
      final ResourcePathParser pathParser,
      final ByteArrayDataOutput respBuf,
      final ChannelHandlerContext ctx,
      final FullHttpRequest request) {
    this(pathParser, respBuf, ctx, request, null);
  }

  public AbastractWebHandler(
      final ResourcePathParser pathParser,
      final ByteArrayDataOutput respBuf,
      final ChannelHandlerContext ctx,
      final FullHttpRequest request,
      final FilterParamParser filterParamParser) {
    this.pathParser = pathParser;
    this.queryParser = new QueryParamsParser(request.uri());
    this.respBuf = respBuf;
    this.ctx = ctx;
    this.request = request;
    this.filterParamParser = filterParamParser;
  }

  @Override
  public ResourcePathParser getPathParser() {
    return pathParser;
  }

  @Override
  public QueryParamsParser getQueryParser() {
    return queryParser;
  }

  @Override
  public ByteArrayDataOutput getRespBuf() {
    return respBuf;
  }

  @Override
  public ChannelHandlerContext getHandlerContext() {
    return ctx;
  }

  @Override
  public FullHttpRequest getRequest() {
    return request;
  }

  @Override
  public Session getSession() {
    return HibernateUtil.getSessionFactory().getCurrentSession();
  }

  @Override
  public Boolean willFilter() {
    return (filterParamParser.paramCount() > 0
        && filterParamParser.containsKey("filter"))
        || filterParamParser.paramCount() > 0;
  }

  public Boolean willSort() {
    return false;
  }

  public Boolean willLimit() {
    return false;
  }

  protected FilterParamParser getFilterParamParser() {
    return filterParamParser;
  }

  /**
   * Dispatch request to handle CRUD(i.e. create, retrieve, update and delete)
   * of resources.
   */
  public FullHttpResponse handle() {
    if (request.method() == GET) { // retrieve
      return handleRetrieval();
    } else if (request.method() == POST) { // create
      return handleCreation();
    } else if (request.method() == PUT) { // update
      return handleUpdate();
    } else if (request.method() == DELETE) { // delete
      return handleDeletion();
    } else {
      return handleNotAllowedMethod(request.method());
    }
  }

  protected static FullHttpResponse newResponse(
      final HttpResponseStatus status,
      final ByteArrayDataOutput respBuf) {
    FullHttpResponse response = new DefaultFullHttpResponse(HTTP_1_1, status,
        Unpooled.copiedBuffer(respBuf.toByteArray()));

    response.headers().set(HttpHeaderNames.CONTENT_TYPE,
        "application/json; charset=UTF-8");
    return response;
  }

  protected FullHttpResponse newResponse(final HttpResponseStatus status) {
    return newResponse(status, getRespBuf());
  }

  protected void appendByteArray(final byte[] byteArray) {
    getRespBuf().write(byteArray);
  }

  public static <T> String toIdJson(final String idKey, final T idVal) {
    if (idVal instanceof String) {
      return String.format("{\"%s\":\"%s\"}", idKey, idVal);
    } else if (idVal instanceof Long || idVal instanceof Integer) {
      return String.format("{\"%s\":%d}", idKey, idVal);
    } else if (idVal == null){
      return String.format("{\"%s\":\"%s\"}", idKey, "null");
    } else {
      return null;
    }
  }

  protected static void appendln(
      final String str,
      final ByteArrayDataOutput respBuf) {
    final String line = String.format("%s%n", str);
    respBuf.write(line.getBytes(CharsetUtil.UTF_8));
  }

  protected void appendln(final String str) {
    appendln(str, getRespBuf());
  }

  protected FullHttpResponse handleRetrieval() {
    return handleNotAllowedMethod(HttpMethod.GET);
  }

  protected FullHttpResponse handleCreation() {
    return handleNotAllowedMethod(HttpMethod.POST);
  }

  protected FullHttpResponse handleUpdate() {
    return handleNotAllowedMethod(HttpMethod.PUT);
  }

  protected FullHttpResponse handleDeletion() {
    return handleNotAllowedMethod(HttpMethod.DELETE);
  }

  private FullHttpResponse handleNotAllowedMethod(final HttpMethod method) {
    appendln(String.format("Method '%s' not allowed.", method.toString()));
    return newResponse(HttpResponseStatus.METHOD_NOT_ALLOWED);
  }

  String stackTraceToString(final Exception e) {
    Writer writer = new StringWriter();
    PrintWriter printWriter = new PrintWriter(writer);
    e.printStackTrace(printWriter);
    return writer.toString();
  }

  void logServerError(final Exception e, final Logger LOG) {
    final String st = stackTraceToString(e);
    LOG.warn(st);
  }

  void stashServerError(final Exception e, final Logger LOG) {
    final String st = stackTraceToString(e);
    LOG.error(st);
    appendln(st);
  }

  FullHttpResponse newClientErrorResponse(final Exception e, final Logger LOG) {
    stashServerError(e, LOG);
    return newResponse(HttpResponseStatus.BAD_REQUEST);
  }

  FullHttpResponse newServerErrorResponse(final Exception e, final Logger LOG) {
    stashServerError(e, LOG);
    return newResponse(HttpResponseStatus.INTERNAL_SERVER_ERROR);
  }

  boolean isEqual(Object a, Object b) {
    return a == null ? b == null : a.equals(b);
  }

  <T> String listToJsonString(final List<T> list) {
    /* build json */
    final StrBuilder sb = new StrBuilder();
    sb.append("[");
    if (list != null) {
      sb.append(Joiner.on(
          ",")
          .skipNulls()
          .join(list));
    }
    sb.append("]");
    return sb.toString();
  }

  protected Map<String, List<String>> addToQueryParams(
      final String key,
      final String val) {
    if (StringUtils.isBlank(key) || StringUtils.isBlank(val)) {
      return getQueryParser().params();
    } else if (getQueryParser().params().isEmpty()) {
      /* new Map since getQueryParser().params() is EmptyMap immutable */
      final Map<String, List<String>> params =
          new LinkedHashMap<String, List<String>>();
      params.computeIfAbsent(key, k -> new ArrayList<>()).add(val);
      return params;
    } else {
      getQueryParser()
        .params()
        .computeIfAbsent(key, k -> new ArrayList<>())
        .add(val);
      return getQueryParser().params();
    }
  }

  protected <T extends ModelBase> FullHttpResponse newResponseForInstance(
      final Long id,
      final String prefix,
      final T instance) throws JsonProcessingException {
    return newResponseForInstance(id.toString(), prefix, instance);
  }

  protected <T extends ModelBase> FullHttpResponse newResponseForInstance(
      final String id,
      final String prefix,
      final T instance) throws JsonProcessingException {
    if (instance != null) {
      appendByteArray(instance.toJsonByteArray());
      return newResponse(HttpResponseStatus.OK);
    } else {
      appendln(String.format("Nonexistent resource with URI: /%s/%s", prefix, id));
      return newResponse(HttpResponseStatus.NOT_FOUND);
    }
  }

  protected <T> T newInstanceFromRequest(final Class<T> clazz)
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return ModelBase.newInstance(json, clazz);
    }
    return null;
  }

  protected <T> List<T> newInstanceAsListFromRequest(final Class<T> clazz)
      throws JsonParseException, JsonMappingException, IOException {
    final ByteBuf content = getRequest().content();
    if (content.isReadable()) {
      final byte[] json = ByteBufUtil.getBytes(content);
      return ModelBase.newInstanceAsList(json, clazz);
    }
    return null;
  }
}
