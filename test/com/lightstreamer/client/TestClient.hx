package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener.BaseClientListener;

@:timeout(2000)
class TestClient extends utest.Test {
  #if android
  var host = "http://10.0.2.2:8080";
  #else
  var host = "http://localhost:8080";
  #end
  var client: LightstreamerClient;
  var listener: BaseClientListener;

  function setup() {
    client = new LightstreamerClient(host, "TEST");
    listener = new BaseClientListener();
    client.addListener(listener);
  }

  function teardown() {
    client.disconnect();
  }

  function connectWithTransport(async: utest.Async, transport: String) {
    client.connectionOptions.setForcedTransport(transport);
    var expected = "CONNECTED:" + transport;
    listener.statusChangeCb = function(status) {
      if (status == expected) {
        pass();
        async.completed();
      }
    };
    client.connect();
  }

  function testConnectWsStreaming(async: utest.Async) {
    connectWithTransport(async, "WS-STREAMING");
  }

  function testConnectHttpStreaming(async: utest.Async) {
    connectWithTransport(async, "HTTP-STREAMING");
  }
}