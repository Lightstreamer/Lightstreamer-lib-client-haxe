package com.lightstreamer.internal;

import com.lightstreamer.client.LightstreamerClient;

@:timeout(1500)
class TestHttpClientNode extends utest.Test {
  var host = "http://localhost:8080";
  var secHost = "https://localhost:8443";
  var output: Array<String>;

  function setup() {
    output = [];
  }

  function teardown() {
    CookieHelper.instance.clearCookies();
  }

  function testPolling(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", null,
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
      "LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", null,
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
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", null,
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
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", null,
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        equals("Network error", error);
        async.completed(); 
      }, 
      function onDone(c) { 
        // next should trigger onError
      });
  }

  function testCookies(async: utest.Async) {
    var uri = host;
    var cookies: Array<String> = LightstreamerClient.getCookies(uri);
    equals(0, cookies.length);
    
    var cookie = "X-Client=client";
    LightstreamerClient.addCookies(uri, [cookie]);

    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg", null,
      function onText(c, line) null, 
      function onError(c, error) { 
        fail(error); 
        async.completed(); 
      }, 
      function onDone(c) {
        var cookies: Array<String> = LightstreamerClient.getCookies(uri);
        equals(2, cookies.length);
        contains("X-Client=client; domain=localhost; path=/", cookies);
        contains("X-Server=server; domain=localhost; path=/", cookies);
        async.completed();
      });
  }

  function testHeaders(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
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
}