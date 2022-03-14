package com.lightstreamer.internal;

import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.client.Proxy;
import com.lightstreamer.internal.NativeTypes.NativeList;

@:timeout(1500)
class TestHttpClientJava extends utest.Test {
  #if android
  var host = "http://10.0.2.2:8080";
  var secHost = "https://10.0.2.2:8443";
  #else
  var host = "http://localhost:8080";
  var secHost = "https://localhost:8443";
  #end
  var output: Array<String>;

  function setup() {
    output = [];
  }

  function teardown() {
    CookieHelper.instance.clearCookies();
    Globals.instance.clearTrustManager();
  }

  function testPolling(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null, null,
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
      "LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null, null,
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
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null, null,
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
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null, null,
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        #if android
        equals("Failed to connect to localhost/127.0.0.1:8443", error);
        #else
        equals("PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target", error);
        #end
        async.completed(); 
      }, 
      function onDone(c) { 
        fail("Unexpected call"); 
        async.completed(); 
      });
  }

  function testCookies(async: utest.Async) {
    var uri = new java.net.URI(host);
    equals(0, LightstreamerClient.getCookies(uri).toHaxe().length);
    
    var cookie = new java.net.HttpCookie("X-Client", "client");
    cookie.setPath("/");
    LightstreamerClient.addCookies(uri, new NativeList([cookie]));

    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null, null,
      function onText(c, line) null, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) {
        var cookies = LightstreamerClient.getCookies(uri).toHaxe().map(c -> c.getName() + "=" + c.getValue());
        equals(2, cookies.length);
        contains("X-Client=client", cookies);
        contains("X-Server=server", cookies);
        async.completed();
      });
  }

  function testHeaders(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", 
      ["X-Header" => "header"], null, null,
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
      #if android
      new Proxy("HTTP", "10.0.2.2", 8079, "myuser", "mypassword"),
      #else
      new Proxy("HTTP", "localhost", 8079, "myuser", "mypassword"),
      #end
      null,
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
    new HttpClient(
      "https://push.lightstreamer.com/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", 
      null,
      #if android
      new Proxy("HTTP", "10.0.2.2", 8079, "myuser", "mypassword"),
      #else
      new Proxy("HTTP", "localhost", 8079, "myuser", "mypassword"),
      #end
      null,
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
    #if android
    var ksIn = TestAll.openRawResource("server_certificate");
    #else
    var bytes = haxe.Resource.getBytes("server_certificate").getData();
    var ksIn = new java.io.ByteArrayInputStream(bytes);
    #end
    var keyStore = java.security.KeyStore.getInstance("PKCS12");
    keyStore.load(ksIn, (cast "secret":java.NativeString).toCharArray());
    var tmf = java.javax.net.ssl.TrustManagerFactory.getInstance(java.javax.net.ssl.TrustManagerFactory.getDefaultAlgorithm());
    tmf.init(keyStore);

    LightstreamerClient.setTrustManagerFactory(tmf);
    new HttpClient(
      secHost + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null, null, 
      Globals.instance.getTrustManagerFactory(),
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