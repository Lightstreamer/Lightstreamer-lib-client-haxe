package com.lightstreamer.internal;

class TestWsClientWeb extends utest.Test {
  var host = "ws://localhost:8080";
  var secHost = "wss://localhost:8443";
  var output: Array<String>;

  function setup() {
    output = [];
  }

  function testPolling(async: utest.Async) {
    new WsClient(
      host + "/lightstreamer",
      function onOpen(c) {
        c.send("create_session\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i");
      },
      function onText(c, line) {
        if (c.isDisposed()) return;
        if (~/LOOP/.match(line)) {
          pass();
          c.dispose();
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
      host + "/lightstreamer",
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
      "wss://push.lightstreamer.com/lightstreamer",
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
      "wss://localhost:8443/lightstreamer", 
      function onOpen(c) {
        fail("Unexpected call"); 
        async.completed(); 
      }, 
      function onText(c, l) { 
        fail("Unexpected call"); 
        async.completed(); 
      },
      function onError(c, error) { 
        equals("Network error", error);
        async.completed(); 
      });
  }
}