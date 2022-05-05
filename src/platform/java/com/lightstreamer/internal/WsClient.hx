package com.lightstreamer.internal;

import okhttp3.*;
import com.lightstreamer.client.Proxy;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.MacroTools.assert;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class WsClient extends WebSocketListener implements Authenticator {
  final ws: WebSocket;
  final proxy: Null<Proxy>;
  final onOpenCb: WsClient->Void;
  final onTextCb: (WsClient, String)->Void;
  final onErrorCb: (WsClient, String)->Void;
  @:volatile var isCanceled: Bool = false;

  public function new(url: String,
    headers: Null<Map<String, String>>, 
    proxy: Null<Proxy>,
    trustManagerFactory: Null<java.javax.net.ssl.TrustManagerFactory>,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    super();
    streamLogger.logDebug('WS connecting: $url headers($headers) proxy($proxy) trustManager($trustManagerFactory)');
    this.proxy = proxy;
    this.onOpenCb = onOpen;
    this.onTextCb = onText;
    this.onErrorCb = onError;
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
    ws.cancel();
  }

  inline public function isDisposed() {
    return isCanceled;
  }

  // WebSocketListener.onOpen
  override public overload function onOpen(webSocket: WebSocket, response: Response) {
    streamLogger.logDebug('WS event: open');
    onOpenCb(this);
  }

  // WebSocketListener.onMessage
  override public overload function onMessage(webSocket: WebSocket, text: String) {
    for (line in text.split("\r\n")) {
      if (line == "") continue;
      streamLogger.logDebug('WS event: text($line)');
      onTextCb(this, line);
    }
  }

  // WebSocketListener.onFailure
  override public overload function onFailure(webSocket: WebSocket, ex: java.lang.Throwable, response: Response) {
    var msg = ex.getMessage();
    streamLogger.logDebug('WS event: error($msg)', ex);
    onErrorCb(this, msg);
    webSocket.cancel();
  }

  // WebSocketListener.onClosing - graceful shutdown
  override public overload function onClosing(webSocket: WebSocket, code: Int, reason: String) {
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