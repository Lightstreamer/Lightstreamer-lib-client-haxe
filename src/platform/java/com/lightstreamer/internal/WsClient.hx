/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi.IWsClient;
import okhttp3.*;
import com.lightstreamer.client.Proxy.LSProxy as Proxy;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.MacroTools.assert;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class WsClient extends WebSocketListener implements Authenticator implements IWsClient {
  final ws: WebSocket;
  final proxy: Null<Proxy>;
  final onOpenCb: WsClient->Void;
  final onTextCb: (WsClient, String)->Void;
  final onErrorCb: (WsClient, String)->Void;
  final onFatalErrorCb: (WsClient, Int, String)->Void;
  @:volatile var isCanceled: Bool = false;

  public function new(url: String,
    headers: Null<Map<String, String>>, 
    proxy: Null<Proxy>,
    trustManagerFactory: Null<java.javax.net.ssl.TrustManagerFactory>,
    certificatePins: Array<String>,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void,
    onFatalError: (WsClient, Int, String)->Void) {
    super();
    streamLogger.logDebug('WS connecting: $url headers($headers) proxy($proxy) trustManager($trustManagerFactory) certificatePins($certificatePins)');
    this.proxy = proxy;
    this.onOpenCb = onOpen;
    this.onTextCb = onText;
    this.onErrorCb = onError;
    this.onFatalErrorCb = onFatalError;
    var reqBuilder = new Request.Request_Builder();
    // set headers
    if (headers != null) {
      for (k => v in headers) {
        reqBuilder.header(k, v);
      }
    }
    // set protocol
    reqBuilder.header("Sec-WebSocket-Protocol", Constants.FULL_TLCP_VERSION);
    // set url
    reqBuilder.url(url);
    var request = reqBuilder.build();
    var clientBuilder = HttpClient.client.newBuilder();
    // set cookies
    var cookieHandler = CookieHelper.instance.getCookieHandler();
    if (cookieHandler != null) {
      clientBuilder.cookieJar(new JavaNetCookieJar(cookieHandler));
    }
    // set proxy
    if (proxy != null) {
      var inet = new java.net.InetSocketAddress(proxy.host, proxy.port);
      var javaProxy = new java.net.Proxy(switch proxy.type {
        case HTTP: java.net.Proxy.Proxy_Type.HTTP;
        case SOCKS4 | SOCKS5: java.net.Proxy.Proxy_Type.SOCKS;
      }, inet);
      clientBuilder.proxy(javaProxy).proxyAuthenticator(@:nullSafety(Off) this);
    }
    // set trust manager
    if (trustManagerFactory != null) {
      // see https://square.github.io/okhttp/4.x/okhttp/okhttp3/-ok-http-client/-builder/ssl-socket-factory/
      var trustManagers = trustManagerFactory.getTrustManagers();
      var x509TrustManager;
      @:nullSafety(Off)
      if (trustManagers.length != 1 || (x509TrustManager = Std.downcast(trustManagers[0], java.javax.net.ssl.X509TrustManager)) == null) {
        throw new IllegalStateException("Unexpected default trust managers:" + java.util.Arrays.toString(trustManagers));
      }
      var sslContext = java.javax.net.ssl.SSLContext.getInstance("TLS");
      @:nullSafety(Off)
      sslContext.init(null, java.NativeArray.make((x509TrustManager:java.javax.net.ssl.TrustManager)), null);
      var sslSocketFactory = sslContext.getSocketFactory();
      clientBuilder.sslSocketFactory(sslSocketFactory, x509TrustManager);
    }
    // set certificate pins
    if (certificatePins.length > 0) {
      var hostname = new java.net.URL(url).getHost();
      var certificatePinner = new CertificatePinner.CertificatePinner_Builder();
      for (pin in certificatePins) {
        certificatePinner.add(hostname, pin);
      }
      clientBuilder.certificatePinner(certificatePinner.build());
    }
    this.ws = clientBuilder.build().newWebSocket(request, this);
  }

  public function send(txt: String) {
    // NB This method returns true if the message was enqueued. Messages that would overflow the 
    // outgoing message buffer (16 MiB) will be rejected and trigger a graceful shutdown of this 
    // web socket. This method returns false in that case, and in any other case where this web 
    // socket is closing, closed, or canceled.
    // https://square.github.io/okhttp/4.x/okhttp/okhttp3/-web-socket/send/#send
    streamLogger.logDebug('WS sending: $txt');
    ws.send(txt);
  }

  public function dispose() {
    streamLogger.logDebug("WS disposing");
    isCanceled = true;
    // **NB** It seems that if `ws.close` is not called before `ws.cancel`, connections may leak.
    // Enabling the OkHttp logger, the following lines may be seen:
    // > WARNING: A connection to http://... was leaked. Did you forget to close a response body?
    // > java.lang.Throwable: response.body().close()
    ws.close(1000, "");
    ws.cancel();
  }

  inline public function isDisposed() {
    return isCanceled;
  }

  // WebSocketListener.onOpen
  override public overload function onOpen(webSocket: WebSocket, response: Response) {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('WS event: open');
    onOpenCb(this);
  }

  // WebSocketListener.onMessage
  override public overload function onMessage(webSocket: WebSocket, text: String) {
    if (isDisposed()) {
      return;
    }
    for (line in text.split("\r\n")) {
      if (isDisposed()) {
        return;
      }
      if (line == "") continue;
      streamLogger.logDebug('WS event: text($line)');
      onTextCb(this, line);
    }
  }

  // WebSocketListener.onFailure
  override public overload function onFailure(webSocket: WebSocket, ex: java.lang.Throwable, response: Response) {
    if (isDisposed()) {
      return;
    }
    if (ex is java.javax.net.ssl.SSLPeerUnverifiedException) {
      streamLogger.logErrorEx2("Connection fatal error", ex);
      onFatalErrorCb(this, 62, "Unrecognized server's identity");
    } else {
      var msg = ex.getMessage();
      streamLogger.logDebugEx2('WS event: error($msg)', ex);
      onErrorCb(this, msg);
    }
    webSocket.cancel();
  }

  // WebSocketListener.onClosing - graceful shutdown
  override public overload function onClosing(webSocket: WebSocket, code: Int, reason: String) {
    if (isDisposed()) {
      return;
    }
    var msg =  "unexpected disconnection: " + code + " - " + reason;
    streamLogger.logDebug('WS event: error($msg)');
    onErrorCb(this, msg);
    webSocket.cancel();
  }

  // Authenticator.authenticate
  public function authenticate(route: Null<Route>, response: Response): Null<Request> {
    assert(proxy != null);
    // see https://square.github.io/okhttp/4.x/okhttp/okhttp3/-authenticator/
    var user = proxy.user == null ? "" : proxy.user;
    var password = proxy.password == null ? "" : proxy.password;
    if (response.request().header("Proxy-Authorization") != null) {
      return null; // Give up, we’ve already failed to authenticate
    }
    var credential = Credentials.basic(user, password);
    return response.request().newBuilder().header("Proxy-Authorization", credential).build();
  }
}