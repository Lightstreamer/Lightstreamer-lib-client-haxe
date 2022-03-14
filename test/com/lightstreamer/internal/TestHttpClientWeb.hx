package com.lightstreamer.internal;

@:timeout(1500)
class TestHttpClientWeb extends utest.Test {
  var host = "http://localhost:8080";
  var secHost = "https://localhost:8443";
  var output: Array<String>;

  function setup() {
    output = [];
  }

  function testPolling(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null,
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
      "LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null,
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
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=DEMO&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null,
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
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", null,
      function onText(c, line) output.push(line), 
      function onError(c, error) { 
        equals("Network error", error);
        async.completed(); 
      }, 
      function onDone(c) { 
        // next should trigger onError
      });
  }

  function testHeaders(async: utest.Async) {
    new HttpClient(
      host + "/lightstreamer/create_session.txt?LS_protocol=TLCP-2.3.0", 
      "LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i", 
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