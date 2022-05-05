package com.lightstreamer.internal;

import okhttp3.*;
import com.lightstreamer.client.Proxy;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.MacroTools.assert;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class HttpClient implements Callback implements Authenticator {
  static final TXT = MediaType.get("application/x-www-form-urlencoded; charset=utf-8");
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

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>, 
    proxy: Null<Proxy>,
    trustManagerFactory: Null<java.javax.net.ssl.TrustManagerFactory>,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
    streamLogger.logDebug('HTTP sending: $url $body headers($headers) proxy($proxy) trustManager($trustManagerFactory)');
    this.proxy = proxy;
    this.onText = onText;
    this.onError = onError;
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
    this.call = clientBuilder.build().newCall(request);
    call.enqueue(this);
  }

  public function dispose() {
    streamLogger.logDebug("HTTP disposing");
    call.cancel();
  }

  inline public function isDisposed() {
    return call.isCanceled();
  }

  // Callback.onFailure
  public function onFailure(call: Call, ex: java.io.IOException) {
    streamLogger.logDebug('HTTP event: error(${ex.getMessage()})', ex);
    onError(this, ex.getMessage());
    call.cancel();
  }

  // Callback.onResponse
	public function onResponse(call: Call, response: Response) {
    if (!response.isSuccessful()) {
      streamLogger.logDebug('HTTP event: error(HTTP code ${response.code()})');
      onError(this, "Unexpected HTTP code: " + response.code());
      call.cancel();
      response.close();
      return;
    }
    try {
      var line;
      var source = response.body().source();
      while ((line = source.readUtf8Line()) != null) {
        streamLogger.logDebug('HTTP event: text($line)');
        onText(this, line);
      }
      streamLogger.logDebug("HTTP event: complete");
      onDone(this);
    } catch(e) {
      streamLogger.logDebugEx('HTTP event: error(${e.message})', e);
      onError(this, e.message);
      call.cancel();
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