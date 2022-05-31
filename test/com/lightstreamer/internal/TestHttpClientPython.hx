package com.lightstreamer.internal;

import com.lightstreamer.client.Proxy;
import com.lightstreamer.client.LightstreamerClient;

@:timeout(1500)
class TestHttpClientPython extends utest.Test {
  var host = "http://localhost:8080";
  var secHost = "https://localhost:8443";
  var output: Array<String>;

  function setup() {
    output = [];
  }

  function teardown() {
    CookieHelper.getInstance().clearCookies();
  }

  function testPolling(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null,
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

  function testStreaming(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null,
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
    new HttpClient(
      "https://push.lightstreamer.com/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null,
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
    new HttpClient(
      "https://localhost:8443/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null,
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        equals("Cannot connect to host localhost:8443 ssl:True [SSLCertVerificationError: (1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self signed certificate (_ssl.c:1129)')]", error);
        async.completed(); 
      }, 
      function onDone(c) { 
        fail("Unexpected call"); 
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

    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null,
      function onText(c, line) null, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) {
        var cookies = LightstreamerClient.getCookies(uri).toHaxeArray();
        equals(2, cookies.count());
        var nCookies = [for (c in cookies) c.output()];
        contains("Set-Cookie: X-Client=client", nCookies);
        contains("Set-Cookie: X-Server=server", nCookies);
        async.completed();
      });
  }

  function testHeaders(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i",
      ["X-Header" => "header"],  null,
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
    new HttpClient(
      "http://localhost:8080/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", 
      null,
      new Proxy("HTTP", "localhost", 8079, "myuser", "mypassword"),
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

  @Ignored
  @:timeout(3000)
  function testProxyHttps(async: utest.Async) {
    new HttpClient(
      "https://push.lightstreamer.com/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", 
      null,
      new Proxy("HTTP", "localhost", 8079, "myuser", "mypassword"),
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