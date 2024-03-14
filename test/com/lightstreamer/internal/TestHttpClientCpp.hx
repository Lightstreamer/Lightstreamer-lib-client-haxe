package com.lightstreamer.internal;

import cpp.Star;
import poco.net.Context;
import com.lightstreamer.internal.Threads.sessionThread;
import com.lightstreamer.internal.NativeTypes.NativeCookieCollection;

// NB the callbacks are sent to another thread because the `dispose` method is not reentrant
private class _HttpClient extends HttpClient {
  public function new(url, body, ?headers, ?proxy, _onText, _onError, _onDone) {
    super(url, body, headers, proxy,
      (c, s) -> sessionThread.submit(() -> _onText(c, s)),
      (c, s) -> sessionThread.submit(() -> _onError(c, s)),
      (c) -> sessionThread.submit(() -> _onDone(c)));
  }
}

@:timeout(1500)
class TestHttpClientCpp extends utest.Test {
  var host = "http://localtest.me:8080";
  var secHost = "https://localtest.me:8443";
  var output: Array<String>;
  var client: HttpClient;

  function setup() {
    output = [];
  }

  function teardown() {
    client.dispose();
    Globals.instance.clearTrustManager();
    CookieHelper.instance.clearCookies();
  }

  function testPolling(async: utest.Async) {
    client = new _HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      function onText(c, line) {
        output.push(line);
      }, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) { 
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed();
      });
  }

  function testStreaming(async: utest.Async) {
    client = new _HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        c.dispose();
        async.completed();
      }, 
      function onError(c, error) {
        if (c.isDisposed()) return;
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) null);
  }

  @:timeout(3000)
  function testHttps(async: utest.Async) {
    client = new _HttpClient(
      "https://push.lightstreamer.com/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) {
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed();
      });
  }

  function testConnectionError(async: utest.Async) {
    client = new _HttpClient(
      secHost + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        equals("SSL Exception", error.substring(0, "SSL Exception".length));
        async.completed(); 
      }, 
      function onDone(c) { 
        fail("Unexpected call"); 
        async.completed(); 
      });
  }

  function testCookies(async: utest.Async) {
    var uri = new poco.URI(host);
    equals(0, (LightstreamerClient.getCookies(uri).size() : Int));
    
    var cookie = new poco.net.HTTPCookie("X-Client", "client");
    var cookies = new NativeCookieCollection();
    cookies.push_back(cookie);
    LightstreamerClient.addCookies(uri, cookies);

    client = new _HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      function onText(c, line) null, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) {
        var cookies = LightstreamerClient.getCookies(uri);
        equals(2, (cookies.size() : Int));
        var c1: String = cookies.at(0).toString();
        var c2: String = cookies.at(1).toString();
        equals("X-Client=client; domain=localtest.me; path=/", c1);
        equals("X-Server=server; domain=localtest.me; path=/", c2);
        async.completed();
      });
  }

  function testHeaders(async: utest.Async) {
    client = new _HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      ["X-Header" => "header"], 
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) { 
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed(); 
      });
  }

  function testProxy(async: utest.Async) {
    client = new _HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"),
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) { 
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed(); 
      });
  }

  @:timeout(3000)
  function testProxyHttps(async: utest.Async) {
    client = new _HttpClient(
      "https://push.lightstreamer.com/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"),
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) { 
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed(); 
      });
  }

  function testTrustManager(async: utest.Async) {
    var privateKeyFile = "test/localtest.me.key";
    var certificateFile = "test/localtest.me.crt";
    var caLocation = "test/localtest.me.crt";
    var pCtx: Star<Context> = new Context(Usage.TLS_CLIENT_USE, privateKeyFile, certificateFile, caLocation);
    var ctxPtr = new ContextPtr(pCtx);

    LightstreamerClient.setTrustManagerFactory(ctxPtr);
    client = new _HttpClient(
      secHost + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", 
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) { 
        isTrue(output.length > 0);
        match(~/CONOK/, output[0]);
        async.completed();
      });
  }
}