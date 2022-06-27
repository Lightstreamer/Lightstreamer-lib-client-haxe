package com.lightstreamer.internal;

import com.lightstreamer.client.LightstreamerClient;
import com.lightstreamer.client.Proxy;

@:timeout(1500)
class TestWsClientCs extends utest.Test {
  var host = "http://localtest.me:8080";
  var secHost = "https://localtest.me:8443";
  var output: Array<String>;

  function setup() {
    output = [];
  }

  function teardown() {
    CookieHelper.instance.clearCookies("ws://localtest.me");
  }

  function testPolling(async: utest.Async) {
    new WsClient(
      host + "/lightstreamer", null, null, null,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
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
        c.send("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
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
      "wss://push.lightstreamer.com/lightstreamer", null, null, null,
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
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
        equals("Unable to connect to the remote server", error);
        async.completed(); 
      });
  }

  function testCookies(async: utest.Async) {
    var uri = new cs.system.Uri(host);
    var cookies: cs.system.net.CookieCollection = LightstreamerClient.getCookies(uri);
    equals(0, cookies.Count);
    
    var cookie = new cs.system.net.Cookie("X-Client", "client");
    var cookies = new cs.system.net.CookieCollection();
    cookies.Add(cookie);
    LightstreamerClient.addCookies(uri, cookies);

    new WsClient(
      host + "/lightstreamer", null, null, null,
      function onOpen(c) {
        var cookies: cs.system.net.CookieCollection = LightstreamerClient.getCookies(uri);
        equals(2, cookies.Count);
        var nCookies = [cookies[0].ToString(), cookies[1].ToString()];
        contains("X-Client=client", nCookies);
        contains("X-Server=server", nCookies);
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
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg");
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