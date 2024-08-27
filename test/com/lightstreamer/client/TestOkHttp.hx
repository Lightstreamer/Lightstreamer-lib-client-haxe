package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener;

class TestOkHttp extends utest.Test {
  
  @:timeout(300000)
  function testLongRequest(async: utest.Async) {
    var client = new LightstreamerClient("http://localtest.me:8080", "TEST");
    // client.connectionOptions.setSessionRecoveryTimeout(0);
    // client.connectionOptions.setForcedTransport("HTTP");
    // client.connectionOptions.setForcedTransport("WS");
    var listener = new BaseClientListener();
    listener._onStatusChange = (status) -> {
      trace(status);
    };
    client.addListener(listener);
    var subListener = new BaseSubscriptionListener();
    subListener._onSubscriptionError = (code, msg) -> {
      trace(code, msg);
    };
    var sub = new Subscription("MERGE", [for (_ in 0...8000) "count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    client.subscribe(sub);
    client.connect();
  }
}