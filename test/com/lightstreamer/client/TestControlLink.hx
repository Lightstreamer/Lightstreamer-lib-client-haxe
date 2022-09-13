package com.lightstreamer.client;

class TestControlLink extends utest.Test {
  var ws: MockWsClient;
  var http: MockHttpClient;
  var ctrl: MockHttpClient;
  var scheduler: MockScheduler;
  var client: LightstreamerClient;

  function setup() {
    ws = new MockWsClient(this);
    http = new MockHttpClient(this);
    ctrl = new MockHttpClient(this, "ctrl");
    scheduler = new MockScheduler(this);
    client = new LightstreamerClient("http://server", "TEST", ws.create, http.create, ctrl.create, scheduler.create);
  }

  function teardown() {
    client.disconnect();
  }

  function testCLink(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,host.com");
      ws.onText("LOOP,0");
    })
    .await("ws.dispose")
    .await("ws.init http://host.com/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }

  function testCLinkAndPort(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,host.com:90");
      ws.onText("LOOP,0");
    })
    .await("ws.dispose")
    .await("ws.init http://host.com:90/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }

  function testCLinkAsIP(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,10.0.0.1");
      ws.onText("LOOP,0");
    })
    .await("ws.dispose")
    .await("ws.init http://10.0.0.1/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }

  function testCLinkPrefix(async: utest.Async) {
    exps
    .then(() -> {
      client = new LightstreamerClient("http://server.com/TestPrefix", "TEST",  ws.create);
      client.connect();
    })
    .await("ws.init http://server.com/TestPrefix/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,host.com/TestPrefix");
      ws.onText("LOOP,0");
    })
    .await("ws.dispose")
    .await("ws.init http://host.com/TestPrefix/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }

  function testCLink_HTTP_STREAMING(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("HTTP-STREAMING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,host.com");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://host.com/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .then(() -> client.connectionOptions.setRequestedMaxBandwidth("40"))
    .await("ctrl.send http://host.com/lightstreamer/control.txt?LS_protocol=TLCP-2.4.0&LS_session=sid\r\nLS_reqId=1&LS_op=constrain&LS_requested_max_bandwidth=40")
    .then(() -> async.completed())
    .verify();
  }

  function testCLink_HTTP_POLLING(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("HTTP-POLLING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,host.com");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://host.com/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=19000&LS_cause=http.loop")
    .then(() -> client.connectionOptions.setRequestedMaxBandwidth("40"))
    .await("ctrl.send http://host.com/lightstreamer/control.txt?LS_protocol=TLCP-2.4.0&LS_session=sid\r\nLS_reqId=1&LS_op=constrain&LS_requested_max_bandwidth=40")
    .then(() -> async.completed())
    .verify();
  }

  function testCLink_WS_POLLING(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("WS-POLLING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,host.com");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://host.com/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }
}