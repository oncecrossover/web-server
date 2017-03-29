/*
 * Copyright 2012 The Netty Project
 *
 * The Netty Project licenses this file to you under the Apache License,
 * version 2.0 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at:
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
package com.snoop.server.web;

import org.jboss.netty.handler.ssl.SslHandler;

import javax.net.ssl.KeyManager;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.Security;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;

/**
 * Creates a bogus {@link SSLContext}. A client-side context created by this
 * factory accepts any certificate even if it is invalid. A server-side context
 * created by this factory sends a bogus certificate defined in
 * {@link SecureChatKeyStore}.
 * <p>
 * You will have to create your context differently in a real world application.
 *
 * <h3>Client Certificate Authentication</h3>
 *
 * To enable client certificate authentication:
 * <ul>
 * <li>Enable client authentication on the server side by calling
 * {@link SSLEngine#setNeedClientAuth(boolean)} before creating
 * {@link SslHandler}.</li>
 * <li>When initializing an {@link SSLContext} on the client side, specify the
 * {@link KeyManager} that contains the client certificate as the first argument
 * of {@link SSLContext#init(KeyManager[], TrustManager[], SecureRandom)}.</li>
 * <li>When initializing an {@link SSLContext} on the server side, specify the
 * proper {@link TrustManager} as the second argument of
 * {@link SSLContext#init(KeyManager[], TrustManager[], SecureRandom)} to
 * validate the client certificate.</li>
 * </ul>
 */
public final class SecureSnoopSslContextFactory {

  private static final String PROTOCOL = "TLS";
  private static final SSLContext SERVER_CONTEXT;
  private static final SSLContext CLIENT_CONTEXT;
  private static final KeyManagerFactory CLIENT_KMF;
  private static final TrustManagerFactory CLIENT_TMF;
  private static final KeyManagerFactory SERVER_KMF;
  private static final TrustManagerFactory SERVER_TMF;

  static {
    String algorithm = Security.getProperty("ssl.KeyManagerFactory.algorithm");
    if (algorithm == null) {
      algorithm = "SunX509";
    }

    SSLContext clientContext = null;
    SSLContext serverContext = null;

    /* get client keystore location */
    final String clientKeyStoreLocation =
        "src/main/resources/com/snoop/server/security/snoop-client-keystore.jks";

    /* get client keystore pwd */
    final String clientKeyStorePassword = "changeme";

    /* get client truststore location */
    final String clientTrustStoreLocation =
        "src/main/resources/com/snoop/server/security/snoop-server-keystore.jks";

    /* get client truststore pwd */
    final String clientTrustStorePassword = "changeme";

    /* init client SSL context */
    try {
      CLIENT_KMF = createKeyManagerFactory(
          clientKeyStoreLocation,
          clientKeyStorePassword,
          algorithm);

      CLIENT_TMF = createTrustManagerFactory(
          clientTrustStoreLocation,
          clientTrustStorePassword,
          algorithm);

      clientContext = SSLContext.getInstance(PROTOCOL);
      clientContext.init(
          CLIENT_KMF.getKeyManagers(),
          CLIENT_TMF.getTrustManagers(),
          null);
    } catch (Exception e) {
      throw new Error("Failed to initialize the client-side SSLContext", e);
    }

    /* get server keystore location */
    final String serverKeyStoreLocation =
        "src/main/resources/com/snoop/server/security/snoop-server-keystore.jks";

    /* get server keystore pwd */
    final String serverKeyStorePassword = "changeme";

    /* get server truststore location */
    final String serverTrustStoreLocation =
        "src/main/resources/com/snoop/server/security/snoop-client-keystore.jks";

    /* get server truststore pwd */
    final String serverTrustStorePassword = "changeme";

    /* init server SSL context */
    try {
      SERVER_KMF = createKeyManagerFactory(
          serverKeyStoreLocation,
          serverKeyStorePassword,
          algorithm);

      SERVER_TMF = createTrustManagerFactory(
          serverTrustStoreLocation,
          serverTrustStorePassword,
          algorithm);

      /* Initialize the SSLContext to work with our key managers */
      serverContext = SSLContext.getInstance(PROTOCOL);
      serverContext.init(
          SERVER_KMF.getKeyManagers(),
          SERVER_TMF.getTrustManagers(),
          null);
    } catch (Exception e) {
      throw new Error("Failed to initialize the server-side SSLContext", e);
    }

    CLIENT_CONTEXT = clientContext;
    SERVER_CONTEXT = serverContext;
  }

  private static KeyManagerFactory createKeyManagerFactory(
      final String serverKeyStoreLocation,
      final String serverKeyStorePassword,
      final String algorithm)
      throws KeyStoreException, NoSuchAlgorithmException, CertificateException,
      FileNotFoundException, IOException, UnrecoverableKeyException {

    /* load keystore */
    final KeyStore ks = KeyStore.getInstance("JKS");
    ks.load(
        new FileInputStream(serverKeyStoreLocation),
        serverKeyStorePassword.toCharArray());

    /* Set up key manager factory to use our keystore */
    final KeyManagerFactory kmf = KeyManagerFactory
        .getInstance(KeyManagerFactory.getDefaultAlgorithm());
    kmf.init(ks, serverKeyStorePassword.toCharArray());

    return kmf;
  }

  private static TrustManagerFactory createTrustManagerFactory(
      final String trustStoreLocation,
      final String trustStorePassword,
      final String algorithm)
      throws KeyStoreException, NoSuchAlgorithmException, CertificateException,
      FileNotFoundException, IOException {

    /* load truststore */
    final KeyStore ts = KeyStore.getInstance("JKS");
    ts.load(
        new FileInputStream(trustStoreLocation),
        trustStorePassword.toCharArray());

    /* set up trust manager factory to use our truststore */
    final TrustManagerFactory tmf = TrustManagerFactory
        .getInstance(TrustManagerFactory.getDefaultAlgorithm());
    tmf.init(ts);

    return tmf;
  }

  public static KeyManagerFactory getClientKeyManagerFactory() {
    return CLIENT_KMF;
  }

  public static TrustManagerFactory getClientTrustManagerFactory() {
    return CLIENT_TMF;
  }
  public static KeyManagerFactory getServerKeyManagerFactory() {
    return SERVER_KMF;
  }

  public static TrustManagerFactory getServerTrustManagerFactory() {
    return SERVER_TMF;
  }

  public static SSLContext getClientContext() {
    return CLIENT_CONTEXT;
  }

  public static SSLContext getServerContext() {
    return SERVER_CONTEXT;
  }

  private SecureSnoopSslContextFactory() {
    // Unused
  }
}
