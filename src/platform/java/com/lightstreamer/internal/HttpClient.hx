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

import com.lightstreamer.internal.PlatformApi.IHttpClient;
import okhttp3.*;
import com.lightstreamer.client.Proxy.LSProxy as Proxy;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.MacroTools.assert;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class HttpClient implements Callback implements Authenticator implements IHttpClient {
  static final TXT = MediaType.get("text/plain; charset=utf-8");
  // OkHttp performs best when you create a single OkHttpClient instance and reuse it for all of your HTTP calls 
  // (see https://square.github.io/okhttp/4.x/okhttp/okhttp3/-ok-http-client/#okhttpclients-should-be-shared)
  // Shutdown isn’t necessary. The threads and connections that are held will be released 
  // automatically if they remain idle 
  // (see https://square.github.io/okhttp/4.x/okhttp/okhttp3/-ok-http-client/#shutdown-isnt-necessary)
  public static final client = new OkHttpClient();
  final call: Call;
  final proxy: Null<Proxy>;
  final onText: (HttpClient, String)->Void;
  final onError: (HttpClient, String)->Void;
  final onDone: HttpClient->Void;
  final onFatalErrorCb: (HttpClient, Int, String)->Void;
  @:volatile var isCanceled: Bool = false;

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>, 
    proxy: Null<Proxy>,
    trustManagerFactory: Null<java.javax.net.ssl.TrustManagerFactory>,
    certificatePins: Array<String>,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onFatalError: (HttpClient, Int, String)->Void,
    onDone: HttpClient->Void) {
    streamLogger.logDebug('HTTP sending: $url $body headers($headers) proxy($proxy) trustManager($trustManagerFactory) certificatePins($certificatePins)');
    this.proxy = proxy;
    this.onText = onText;
    this.onError = onError;
    this.onFatalErrorCb = onFatalError;
    this.onDone = onDone;
    var reqBuilder = new Request.Request_Builder();
    // set headers
    if (headers != null) {
      for (k => v in headers) {
        reqBuilder.header(k, v);
      }
    }
    // set url and url body
    var request = reqBuilder.url(url).post(RequestBody.create(body, TXT)).build();
    var clientBuilder = client.newBuilder();
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
    this.call = clientBuilder.build().newCall(request);
    call.enqueue(this);
  }

  public function dispose() {
    streamLogger.logDebug("HTTP disposing");
    isCanceled = true;
    call.cancel();
  }

  inline public function isDisposed() {
    return isCanceled;
  }

  // Callback.onFailure
  public function onFailure(call: Call, ex: java.io.IOException) {
    if (isDisposed()) {
      return;
    }
    if (ex is java.javax.net.ssl.SSLPeerUnverifiedException) {
      streamLogger.logErrorEx2("Connection fatal error", ex);
      onFatalErrorCb(this, 62, "Certificate pinning failure");
    } else {
      streamLogger.logDebugEx2('HTTP event: error(${ex.getMessage()})', ex);
      onError(this, ex.getMessage());
    }
    call.cancel();
  }

  // Callback.onResponse
	public function onResponse(call: Call, response: Response) {
    if (isDisposed()) {
      response.close();
      return;
    }
    if (!response.isSuccessful()) {
      streamLogger.logDebug('HTTP event: error(HTTP code ${response.code()})');
      onError(this, "Unexpected HTTP code: " + response.code());
      response.close();
      return;
    }
    try {
      var line;
      var source = response.body().source();
      while ((line = source.readUtf8Line()) != null) {
        if (isDisposed()) {
          response.close();
          return;
        }
        streamLogger.logDebug('HTTP event: text($line)');
        onText(this, line);
      }
      streamLogger.logDebug("HTTP event: complete");
      onDone(this);
    } catch(e) {
      if (isDisposed()) {
        response.close();
        return;
      }
      streamLogger.logDebugEx('HTTP event: error(${e.message})', e);
      onError(this, e.message);
    }
    response.close();
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