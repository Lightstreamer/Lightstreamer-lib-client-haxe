package com.lightstreamer.internal;

import com.lightstreamer.client.Proxy;
import com.lightstreamer.client.LightstreamerClient;

@:timeout(1500)
class TestWsClientPython extends utest.Test {
  var host = "http://localtest.me:8080";
  var secHost = "https://localtest.me:8443";
  var output: Array<String>;

  function setup() {
    output = [];
  }

  function teardown() {
    CookieHelper.instance.clearCookies();
    Globals.instance.clearTrustManager();
  }

  function testPolling(async: utest.Async) {
    new WsClient(
      host + "/lightstreamer", null, null, null,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        if (~/LOOP/.match(line)) {
          pass();
          async.completed(); 
        }
      }, 
      function onError(c, error) {
        if (c.isDisposed()) return;
        fail(error); 
        async.completed(); 
      });
  }

  function testStreaming(async: utest.Async) {
    new WsClient(
      host + "/lightstreamer", null, null, null,
      function onOpen(c) {
        c.send("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
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
      });
  }

  @:timeout(3000)
  function testHttps(async: utest.Async) {
    new WsClient(
      "https://push.lightstreamer.com/lightstreamer", null, null, null,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
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
      });
  }

  function testConnectionError(async: utest.Async) {
    new WsClient(
      secHost + "/lightstreamer", 
      null, null, null,
      function onOpen(c) {
        fail("Unexpected call"); 
        async.completed(); 
      }, 
      function onText(c, l) { 
        fail("Unexpected call"); 
        async.completed(); 
      },
      function onError(c, error) { 
        equals("Cannot connect to host localtest.me:8443 ssl:True [SSLCertVerificationError: (1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self signed certificate (_ssl.c:1129)')]", error);
        async.completed(); 
      });
  }

  function testCookies(async: utest.Async) {
    var uri = host;
    equals(0, LightstreamerClient.getCookies(uri).toHaxeArray().count());
    
    var dict = new python.Dict<String, String>();
    dict.set("X-Client", "client");
    var cookies = new SimpleCookie(dict);
    LightstreamerClient.addCookies(uri, cookies);

    new WsClient(
      host + "/lightstreamer", null, null, null,
      function onOpen(c) {
        var cookies = LightstreamerClient.getCookies(uri).toHaxeArray();
        equals(2, cookies.count());
        var nCookies = [for (c in cookies) c.output()];
        contains("Set-Cookie: X-Client=client", nCookies);
        contains("Set-Cookie: X-Server=server", nCookies);
        c.dispose();
        async.completed();
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
      }, 
      function onError(c, error) {
        if (c.isDisposed()) return;
        fail(error); 
        async.completed(); 
      });
  }

  function testHeaders(async: utest.Async) {
    new WsClient(
      host + "/lightstreamer", 
      ["X-Header" => "header"], null, null,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
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
      });
  }

  function testProxy(async: utest.Async) {
    new WsClient(
      host + "/lightstreamer", 
      null,
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"), null,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
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
      });
  }

  @:timeout(3000)
  function testProxyHttps(async: utest.Async) {
    // see https://docs.aiohttp.org/en/stable/client_advanced.html#ssl-control-for-tcp-sockets
    var sslcontext = SSLContext.SSL.create_default_context({cafile: "test/mitmproxy-ca-cert.pem"});
    new WsClient(
      "https://push.lightstreamer.com/lightstreamer", 
      null,
      new Proxy("HTTP", "localtest.me", 8079, "myuser", "mypassword"), sslcontext,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
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
      });
  }

  function testTrustManager(async: utest.Async) {
    // see https://docs.aiohttp.org/en/stable/client_advanced.html#ssl-control-for-tcp-sockets
    var sslcontext = SSLContext.SSL.create_default_context({cafile: "test/localtest.me.crt"});
    sslcontext.load_cert_chain({certfile: "test/localtest.me.crt", keyfile: "test/localtest.me.key"});

    LightstreamerClient.setTrustManagerFactory(sslcontext);
    new WsClient(
      secHost + "/lightstreamer", null, null, 
      Globals.instance.getTrustManagerFactory(),
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
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
      });
  }
}