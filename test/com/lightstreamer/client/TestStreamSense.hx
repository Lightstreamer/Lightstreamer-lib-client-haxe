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
    client = new LightstreamerClient("http://server", "TEST", new TestFactory(this, ws, http, ctrl, scheduler));
  }

  function teardown() {
    client.disconnect();
  }

  #if LS_WEB
  /**
   * When the user sets some headers
   * But he doesn't set flag httpExtraHeadersOnSessionCreationOnly
   * Then the client sends both create_session and bind_session in HTTP
   */
  function testExtraHeaders_NotOnCreationOnly(async: utest.Async) {
    client.connectionOptions.setHttpExtraHeaders(["H"=>"h"]);

    var listener = new BaseListener.BaseClientListener();
    listener._onStatusChange = (status) -> exps.signal(status);
    client.addListener(listener);

    exps
    .then(() -> client.connect())
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("CONNECTING")
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:STREAM-SENSING")
    .await("CONNECTED:HTTP-STREAMING")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * When the user sets some headers
   * And he does set flag httpExtraHeadersOnSessionCreationOnly
   * Then the client sends create_session in HTTP and bind_session in WS
   */
  function testExtraHeaders_OnCreationOnly(async: utest.Async) {
    client.connectionOptions.setHttpExtraHeaders(["H"=>"h"]);
    client.connectionOptions.setHttpExtraHeadersOnSessionCreationOnly(true);

    var listener = new BaseListener.BaseClientListener();
    listener._onStatusChange = (status) -> exps.signal(status);
    client.addListener(listener);

    exps
    .then(() -> client.connect())
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("CONNECTING")
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("CONNECTED:STREAM-SENSING")
    .await("wsok")
    .await("bind_session\r\nLS_session=sid&LS_send_sync=false&LS_cause=http.loop")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:WS-STREAMING")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * When the user sets some headers
   * And he chooses a transport not supporting headers
   * But he doesn't set flag httpExtraHeadersOnSessionCreationOnly
   * Then the client is unable to connect
   */
  function testExtraHeaders_NotOnCreationOnly_ForceWS(async: utest.Async) {
    client.connectionOptions.setHttpExtraHeaders(["H"=>"h"]);
    client.connectionOptions.setForcedTransport("WS");

    exps
    .then(() -> client.connect())
    .then(() -> equals("DISCONNECTED", client.getStatus()))
    .then(() -> async.completed())
    .verify();
  }

  /**
   * When the client aborts a session
   * Then, before creating the next one, it checks if a connection is possible
   */
  function testExtraHeaders_Retry(async: utest.Async) {
    client.connectionOptions.setHttpExtraHeaders(["H"=>"h"]);
    client.connectionOptions.setHttpExtraHeadersOnSessionCreationOnly(true);
    client.connectionOptions.setForcedTransport("WS");

    var listener = new BaseListener.BaseClientListener();
    listener._onStatusChange = (status) -> exps.signal(status);
    client.addListener(listener);
    
    exps
    .then(() -> client.connect())
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      client.connectionOptions.setHttpExtraHeadersOnSessionCreationOnly(false);
      http.onError();
    })
    .await("CONNECTING")
    .await("http.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> scheduler.fireRetryTimeout())
    .await("DISCONNECTED")
    .then(() -> async.completed())
    .verify();
  }
  #end

  function testForcePolling_StreamingNotAvailable(async: utest.Async) {
    exps
    .then(() -> client.connect())
    .await("ws.init http://server/lightstreamer")
    .then(() -> {
      ws.onError();
    })
    .await("ws.dispose")
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=ws.unavailable")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> scheduler.fireTransportTimeout())
    .await("ws.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=ws.unavailable")
    .then(() -> scheduler.fireTransportTimeout())
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=force_rebind&LS_cause=http.streaming.unavailable")
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
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=19000&LS_cause=http.loop")
    .then(() -> http.onText("CONOK,sid,70000,5000,*"))
    .then(() -> async.completed())
    .verify();
  }
}