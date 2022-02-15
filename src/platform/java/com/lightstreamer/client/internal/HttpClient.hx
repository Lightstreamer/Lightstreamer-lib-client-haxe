package com.lightstreamer.client.internal;

import okhttp3.*;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class HttpClient {
  static final TXT = MediaType.get("text/plain; charset=utf-8");
  // OkHttp performs best when you create a single OkHttpClient instance and reuse it for all of your HTTP calls 
  // (see https://square.github.io/okhttp/4.x/okhttp/okhttp3/-ok-http-client/#okhttpclients-should-be-shared)
  // Shutdown isn’t necessary. The threads and connections that are held will be released 
  // automatically if they remain idle 
  // (see https://square.github.io/okhttp/4.x/okhttp/okhttp3/-ok-http-client/#shutdown-isnt-necessary)
  public static final client = new OkHttpClient();
  final call: Call;

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>, 
    proxy: Null<Proxy>,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
    streamLogger.logDebug('HTTP sending: $url $body headers($headers) proxy($proxy)');
    var reqBuilder = new Request.Request_Builder();
    // set headers
    if (headers != null) {
      for (k => v in headers) {
        reqBuilder.header(k, v);
      }
    }
    // set proxy credentials
    if (proxy != null && proxy.user != null) {
      var user = proxy.user;
      var password = proxy.password != null ? proxy.password : "";
      reqBuilder.header("Proxy-Authorization", Credentials.basic(user, password));
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
      clientBuilder.proxy(javaProxy);
    }
    this.call = clientBuilder.build().newCall(request);
    call.enqueue(new HttpCallback(this, onText, onError, onDone));
  }

  public function dispose() {
    streamLogger.logDebug("HTTP disposing");
    call.cancel();
  }

  inline public function isDisposed() {
    return call.isCanceled();
  }
}

private class HttpCallback implements Callback {
  final client: HttpClient;
  final onText: (HttpClient, String)->Void;
  final onError: (HttpClient, String)->Void;
  final onDone: HttpClient->Void;

  public function new(client: HttpClient,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
    this.client = client;
    this.onText = onText;
    this.onError = onError;
    this.onDone = onDone;
  }

	public function onFailure(call: Call, ex: java.io.IOException) {
    streamLogger.logDebug('HTTP event: error(${ex.getMessage()})');
    onError(client, ex.getMessage());
    call.cancel();
  }

	public function onResponse(call: Call, response: Response) {
    if (!response.isSuccessful()) {
      streamLogger.logDebug('HTTP event: error(HTTP code ${response.code()})');
      onError(client, "Unexpected HTTP code: " + response.code());
      call.cancel();
      response.close();
      return;
    }
    try {
      var line;
      var source = response.body().source();
      while ((line = source.readUtf8Line()) != null) {
        streamLogger.logDebug('HTTP event: text($line)');
        onText(client, line);
      }
      streamLogger.logDebug("HTTP event: complete");
      onDone(client);
    } catch(e) {
      streamLogger.logDebug('HTTP event: error(${e.message})');
      onError(client, e.message);
      call.cancel();
    }
    response.close();
  }
}