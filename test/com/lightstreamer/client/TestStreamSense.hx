package com.lightstreamer.client;

class TestStreamSense extends utest.Test {
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

  function testForcePolling_StreamingNotAvailable(async: utest.Async) {
    exps
    .then(() -> client.connect())
    .await("ws.init http://server/lightstreamer")
    .then(() -> {
      ws.onError();
    })
    .await("ws.dispose")
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=ws.unavailable")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> scheduler.fireTransportTimeout())
    .await("ws.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=ws.unavailable")
    .then(() -> scheduler.fireTransportTimeout())
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.4.0&LS_session=sid\r\nLS_reqId=1&LS_op=force_rebind&LS_cause=http.streaming.unavailable")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.4.0\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=19000&LS_cause=http.loop")
    .then(() -> http.onText("CONOK,sid,70000,5000,*"))
    .then(() -> async.completed())
    .verify();
  }
}