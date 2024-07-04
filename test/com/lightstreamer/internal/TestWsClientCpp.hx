package com.lightstreamer.internal;

import cpp.Star;

private class _WsClient extends WsClient {
  public function new(url, ?headers, ?proxy, _onOpen, _onText, _onError) {
    super(url, headers, proxy, _onOpen, _onText, _onError);
  }
}

@:timeout(2000)
class TestWsClientCpp extends utest.Test {
  var host = "http://localtest.me:8080";
  var secHost = "https://localtest.me:8443";
  var output: Array<String>;
  var ws: WsClient;

  function setup() {
    output = [];
  }

  function teardown() {
    ws.dispose();
    #if LS_HAS_COOKIES
    CookieHelper.instance.clearCookies();
    #end
    #if LS_HAS_TRUST_MANAGER
    Globals.instance.clearTrustManager();
    #end
  }

  function testPolling(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer",
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (~/LOOP/.match(line)) {
          pass();
          async.completed(); 
        }
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  function testStreaming(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer", 
      function onOpen(c) {
        c.send("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      });
  }

  @:timeout(3000)
  function testHttps(async: utest.Async) {
    ws = new _WsClient(
      "https://push.lightstreamer.com/lightstreamer", 
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      });
  }

  function testConnectionError(async: utest.Async) {
    ws = new _WsClient(
      secHost + "/lightstreamer", 
      function onOpen(c) {
        fail("Unexpected call"); 
        async.completed(); 
      }, 
      function onText(c, l) { 
        fail("Unexpected call"); 
        async.completed(); 
      },
      function onError(c, error) { 
        equals("SSL Exception", error.substring(0, "SSL Exception".length));
        async.completed(); 
      });
  }

  #if LS_HAS_COOKIES
  function testCookies(async: utest.Async) {
    var uri = new poco.URI(host);
    equals(0, (LightstreamerClient.getCookies(uri).size() : Int));
    
    var cookie = new poco.net.HTTPCookie("X-Client", "client");
    var cookies = new NativeCookieCollection();
    cookies.push_back(cookie);
    LightstreamerClient.addCookies(uri, cookies);

    ws = new _WsClient(
      host + "/lightstreamer",
      function onOpen(c) {
        var cookies = LightstreamerClient.getCookies(uri);
        equals(2, (cookies.size() : Int));
        var c1: String = cookies.at(0).toString();
        var c2: String = cookies.at(1).toString();
        equals("X-Client=client; domain=localtest.me; path=/", c1);
        equals("X-Server=server; domain=localtest.me; path=/", c2);
        async.completed();
      },
      function onText(c, line) {
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }
  #end

  function testHeaders(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer", 
      ["X-Header" => "header"],
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  function testProxy(async: utest.Async) {
    ws = new _WsClient(
      host + "/lightstreamer", 
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"),
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  @:timeout(3000)
  function testProxyHttps(async: utest.Async) {
    ws = new _WsClient(
      "https://push.lightstreamer.com/lightstreamer", 
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"),
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  #if LS_HAS_TRUST_MANAGER
  function testTrustManager(async: utest.Async) {
    var privateKeyFile = "test/localtest.me.key";
    var certificateFile = "test/localtest.me.crt";
    var caLocation = "test/localtest.me.crt";
    var pCtx: Star<Context> = new Context(Usage.TLS_CLIENT_USE, privateKeyFile, certificateFile, caLocation);
    var ctxPtr = new ContextPtr(pCtx);

    LightstreamerClient.setTrustManagerFactory(ctxPtr);
    ws = new _WsClient(
      secHost + "/lightstreamer",
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        match(~/CONOK/, line);
        async.completed();
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }
  #end
}