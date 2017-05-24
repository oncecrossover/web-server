package com.snoop.server.web;

import java.io.Closeable;
import java.io.IOException;
import java.util.concurrent.TimeoutException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Supplier;
import com.snoop.server.test.GenericTestUtils;

import io.netty.handler.codec.http.HttpContent;
import io.netty.handler.codec.http.HttpMethod;
import io.netty.handler.codec.http.HttpResponse;

public class MiniSnoopClient implements Closeable {
  private static final Logger LOG = LoggerFactory
      .getLogger(MiniSnoopClient.class);

  public static class Builder {
    public Builder() {
      sslEnabled = System.getProperty("http.snoop.ssl") != null;
      host = "127.0.0.1";
      port = Integer
          .parseInt(System.getProperty("http.snoop.server.port", "0"));
    }

    public MiniSnoopClient build() throws IOException {
      return new MiniSnoopClient(this);
    }

    private String host;
    private int port;
    private boolean sslEnabled;

    public Builder host(final String host) {
      this.host = host;
      return this;
    }

    public Builder port(final int port) {
      this.port = port;
      return this;
    }

    public Builder sslEnabled(final boolean sslEnabled) {
      this.sslEnabled = sslEnabled;
      return this;
    }
  }

  public enum HttpType {
    GET("GET", HttpMethod.GET),
    PUT("PUT", HttpMethod.PUT),
    POST("POST", HttpMethod.POST),
    DELETE("DELETE", HttpMethod.DELETE);

    private String code;
    private HttpMethod value;

    HttpType(final String code, final HttpMethod value) {
      this.code = code;
      this.value = value;
    }

    public String code() {
      return code;
    }

    public HttpMethod value() {
      return value;
    }
  }

  /**
   * Sends request through http GET method.
   * @param resourceUri
   *          uri of resoure, e.g. users/edmund.
   */
  public void sendRequest(final String resourceUri) {
    httpSnoopClient.sendRequest(HttpType.GET.value, resourceUri, null);
  }

  /**
   * Sends request through a specific http method.
   * @param httpType
   *          http method, e.g. GET, PUT or POST.
   * @param resourceUri
   *          uri of resoure, e.g. usrs/edmund.
   */
  public void sendRequest(final HttpType httpType, final String resourceUri) {
    httpSnoopClient.sendRequest(httpType.value, resourceUri, null);
  }

  /**
   * Sends request through a specific http method.
   * @param httpType
   *          http method, e.g. GET, PUT or POST.
   * @param resourceUri
   *          uri of resoure, e.g. usrs/edmund.
   * @param content
   *          http content.
   */
  public void sendRequest(final HttpType httpType, final String resourceUri,
      final byte[] content) {
    httpSnoopClient.sendRequest(httpType.value, resourceUri, content);
  }

  public String getHost() {
    return httpSnoopClient.getHost();
  }

  public int getPort() {
    return httpSnoopClient.getPort();
  }

  public boolean getSslEnabled() {
    return httpSnoopClient.getSslEnabled();
  }

  private MiniHttpSnoopClient httpSnoopClient;

  private MiniSnoopClient(final Builder builder) throws IOException {
    httpSnoopClient = new MiniHttpSnoopClient(builder.host, builder.port,
        builder.sslEnabled);
  }

  private HttpSnoopClientHandler getHttpClientHandler() {
    return httpSnoopClient.getHttpClientInitializer().getHttpClientHandler();
  }

  public HttpResponse getHttpResponse() {
    return getHttpClientHandler().getHttpResponse();
  }

  public HttpContent getHttpContent() {
    return getHttpClientHandler().getHttpContent();
  }

  public void waitForHttpResponse()
      throws TimeoutException, InterruptedException {
    GenericTestUtils.waitFor(new Supplier<Boolean>() {
      @Override
      public Boolean get() {
        final boolean result = getHttpClientHandler().getHttpResponse() == null
            ? false : true;
        LOG.info("http response ready ? " + result);
        return result;
      }
    }, 10, 60000);
  }

  public void waitForHttpContent()
      throws TimeoutException, InterruptedException {
    GenericTestUtils.waitFor(new Supplier<Boolean>() {
      @Override
      public Boolean get() {
        final boolean result = getHttpClientHandler().getHttpContent() == null
            ? false : true;
        LOG.info("http content ready ? " + result);
        return result;
      }
    }, 10, 60000);
  }

  @Override
  public void close() throws IOException {
    try {
      httpSnoopClient.waitChannelClosed();

      GenericTestUtils.waitFor(new Supplier<Boolean>() {
        @Override
        public Boolean get() {
          final boolean channelClosed = httpSnoopClient.getChannelClosed();
          LOG.info("mini client channel closed ? " + channelClosed);
          return channelClosed;
        }
      }, 100, 60000);

      httpSnoopClient.shutDown();
    } catch (TimeoutException | InterruptedException e) {
      throw new IOException(e);
    }
  }
}
