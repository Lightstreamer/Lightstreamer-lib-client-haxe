package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener;

@:timeout(2000)
@:build(utils.Macros.parameterize(["WS-STREAMING", "HTTP-STREAMING", "WS-POLLING", "HTTP-POLLING"]))
class TestClientExtra extends utest.Test {
  #if android
  var host = "http://10.0.2.2:8080";
  #else
  var host = "http://localtest.me:8080";
  #end
  var client: LightstreamerClient;
  var listener: BaseClientListener;
  var subListener: BaseSubscriptionListener;
  var msgListener: BaseMessageListener;
  var connectedString: String;

  function setup() {
    clearGlobalSettings();
    client = new LightstreamerClient(host, "TEST");
    listener = new BaseClientListener();
    subListener = new BaseSubscriptionListener();
    msgListener = new BaseMessageListener();
    client.addListener(listener);
  }

  function teardown() {
    client.disconnect();
    clearGlobalSettings();
  }

  function clearGlobalSettings() {
    #if LS_HAS_COOKIES
      #if cs
      com.lightstreamer.internal.CookieHelper.instance.clearCookies(host);
      #else
      com.lightstreamer.internal.CookieHelper.instance.clearCookies();
      #end
    #end
    #if (LS_HAS_TRUST_MANAGER && !cs)
    com.lightstreamer.internal.Globals.instance.clearTrustManager();
    #end
  }

  #if LS_HAS_COOKIES
  function _testCookies(async: utest.Async) {
    setTransport();
    exps
    .then(() -> {
      #if python
      var cookies0 = LightstreamerClient.getCookies(host).toHaxeArray();
      equals(0, cookies0.length);

      var dict = new python.Dict<String, String>();
      dict.set("X-Client", "client");
      var cookies = new com.lightstreamer.internal.SimpleCookie(dict);
      LightstreamerClient.addCookies(host, cookies);
      #elseif LS_NODE
      var cookies: Array<String> = LightstreamerClient.getCookies(host);
      equals(0, cookies.length);

      var cookie = "X-Client=client";
      LightstreamerClient.addCookies(host, [cookie]);
      #elseif java
      var uri = new java.net.URI(host);
      equals(0, LightstreamerClient.getCookies(uri).toHaxe().length);
      
      var cookie = new java.net.HttpCookie("X-Client", "client");
      cookie.setPath("/");
      LightstreamerClient.addCookies(uri, new com.lightstreamer.internal.NativeTypes.NativeList([cookie]));
      #elseif cs
      var uri = new cs.system.Uri(host);
      var cookies: cs.system.net.CookieCollection = LightstreamerClient.getCookies(uri);
      equals(0, cookies.Count);

      var cookie = new cs.system.net.Cookie("X-Client", "client");
      var cookies = new cs.system.net.CookieCollection();
      cookies.Add(cookie);
      LightstreamerClient.addCookies(uri, cookies);
      #elseif cpp
      var uri = host;
      equals(0, LightstreamerClient.getCookies(uri).length);
      
      var cookies = [ "X-Client=client" ];
      LightstreamerClient.addCookies(uri, cookies);
      #else
      fail("to be implemented");
      #end

      listener._onStatusChange = status -> if (status == connectedString) exps.signal("connected");
      client.connect();
    })
    .await("connected")
    .then(() -> {
      #if python
      var cookies = LightstreamerClient.getCookies(host).toHaxeArray();
      equals(2, cookies.count());
      var nCookies = [for (c in cookies) c.output()];
      contains("Set-Cookie: X-Client=client", nCookies);
      contains("Set-Cookie: X-Server=server", nCookies);
      #elseif LS_NODE
      var cookies: Array<String> = LightstreamerClient.getCookies(host);
      equals(2, cookies.length);
      contains("X-Client=client; domain=localtest.me; path=/", cookies);
      contains("X-Server=server; domain=localtest.me; path=/", cookies);
      #elseif java
      var uri = new java.net.URI(host);
      var cookies = LightstreamerClient.getCookies(uri).toHaxe().map(c -> c.getName() + "=" + c.getValue());
      equals(2, cookies.length);
      contains("X-Client=client", cookies);
      contains("X-Server=server", cookies);
      #elseif cs
      var uri = new cs.system.Uri(host);
      var cookies: cs.system.net.CookieCollection = LightstreamerClient.getCookies(uri);
      equals(2, cookies.Count);
      var nCookies = [cookies[0].ToString(), cookies[1].ToString()];
      contains("X-Client=client", nCookies);
      contains("X-Server=server", nCookies);
      #elseif cpp
      var uri = host;
      var cookies = LightstreamerClient.getCookies(uri);
      equals(2, cookies.length);
      var c1: String = cookies[0].toString();
      var c2: String = cookies[1].toString();
      equals("X-Client=client; domain=localtest.me; path=/", c1);
      equals("X-Server=server; domain=localtest.me; path=/", c2);
      #else
      fail("to be implemented");
      #end
    })
    .then(() -> async.completed())
    .verify();
  }
  #end

  #if (LS_HAS_TRUST_MANAGER && !cs)
  function _testTrustManager(async: utest.Async) {
    client = new LightstreamerClient("https://localtest.me:8443", "TEST");
    client.addListener(listener);
    setTransport();
    exps
    .then(() -> {
      #if python
      var sslcontext = com.lightstreamer.internal.SSLContext.SSL.create_default_context({cafile: "test/localtest.me.crt"});
      sslcontext.load_cert_chain({certfile: "test/localtest.me.crt", keyfile: "test/localtest.me.key"});
      LightstreamerClient.setTrustManagerFactory(sslcontext);
      #elseif java
      var ksIn = getResourceAsJavaBytes("server_certificate");
      var keyStore = java.security.KeyStore.getInstance("PKCS12");
      keyStore.load(ksIn, (cast "secret":java.NativeString).toCharArray());
      var tmf = java.javax.net.ssl.TrustManagerFactory.getInstance(java.javax.net.ssl.TrustManagerFactory.getDefaultAlgorithm());
      tmf.init(keyStore);
      LightstreamerClient.setTrustManagerFactory(tmf);
      #elseif cpp
      var privateKeyFile = "test/localtest.me.key";
      var certificateFile = "test/localtest.me.crt";
      var caLocation = "test/localtest.me.crt";
      LightstreamerClient.setTrustManagerFactory(caLocation, certificateFile, privateKeyFile, "", true);
      #else
      fail("to be implemented");
      #end
      listener._onStatusChange = status -> if (status == connectedString) exps.signal("connected");
      client.connect();
    })
    .await("connected")
    .then(() -> async.completed())
    .verify();
  }
  #end

  function setTransport() {
    client.connectionOptions.setForcedTransport(_param);
    connectedString = "CONNECTED:" + _param;
    if (_param.endsWith("POLLING")) {
      client.connectionOptions.setIdleTimeout(0);
      client.connectionOptions.setPollingInterval(100);
    }
  }
}