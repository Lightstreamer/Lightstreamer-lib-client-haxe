package com.lightstreamer.internal;

import com.lightstreamer.client.LightstreamerClient;

class TestWsClientNode extends utest.Test {
  var host = "ws://localhost:8080";
  var secHost = "wss://localhost:8443";
  var output: Array<String>;
  var ws: WsClient;

  function setup() {
    output = [];
  }

  function teardown() {
    ws.dispose();
    CookieHelper.instance.clearCookies();
  }

  function testPolling(async: utest.Async) {
    ws = new WsClient(
      host + "/lightstreamer", null,
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
    ws = new WsClient(
      host + "/lightstreamer", null,
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
    ws = new WsClient(
      "wss://push.lightstreamer.com/lightstreamer", null,
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
    ws = new WsClient(
      "wss://localhost:8443/lightstreamer", null,
      function onOpen(c) {
        fail("Unexpected call"); 
        async.completed(); 
      }, 
      function onText(c, l) { 
        fail("Unexpected call"); 
        async.completed(); 
      },
      function onError(c, error) { 
        equals("Network error: Error - self signed certificate", error);
        async.completed(); 
      });
  }

  function testCookies(async: utest.Async) {
    var uri = host;
    var cookies: Array<String> = LightstreamerClient.getCookies(uri);
    equals(0, cookies.length);
    
    var cookie = "X-Client=client";
    LightstreamerClient.addCookies(uri, [cookie]);

    ws = new WsClient(
      host + "/lightstreamer", null,
      function onOpen(c) {
        var cookies: Array<String> = LightstreamerClient.getCookies(uri);
        equals(2, cookies.length);
        contains("X-Client=client; domain=localhost; path=/", cookies);
        contains("X-Server=server; domain=localhost; path=/", cookies);
        async.completed();
      },
      function onText(c, line) {
      }, 
      function onError(c, error) {
        fail(error); 
        async.completed(); 
      });
  }

  function testHeaders(async: utest.Async) {
    ws = new WsClient(
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
}