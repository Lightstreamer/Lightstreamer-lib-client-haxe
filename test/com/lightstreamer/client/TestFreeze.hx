package com.lightstreamer.client;

import com.lightstreamer.client.internal.ClientMachine;
import com.lightstreamer.client.BaseListener.BaseClientListener;

class TestFreeze extends utest.Test {
  var ws: MockWsClient;
  var http: MockHttpClient;
  var ctrl: MockHttpClient;
  var scheduler: MockScheduler;
  var client: LightstreamerClient;
  var listener: BaseClientListener;
  var page: MockPageLifecycle;

  @:access(com.lightstreamer.client.internal.ClientMachine.frz_globalPageLifecycle)
  function setup() {
    ws = new MockWsClient(this);
    http = new MockHttpClient(this);
    ctrl = new MockHttpClient(this, "ctrl");
    scheduler = new MockScheduler(this);
    page = new MockPageLifecycle();
    client = new LightstreamerClient("http://server", "TEST", new TestFactory(this, ws, http, ctrl, scheduler, page));
    ClientMachine.frz_globalPageLifecycle = page;
    listener = new BaseClientListener();
    listener._onStatusChange = status -> exps.signal(status);
    client.addListener(listener);
  }

  function teardown() {
    client.disconnect();
  }

  function testCreateWs(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> {
      page.freeze();
    })
    .await("CONNECTED:WS-STREAMING")
    .await("control\r\nLS_reqId=1&LS_op=destroy&LS_close_socket=true&LS_cause=page.frozen")
    .await("ws.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=page.frozen")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:WS-STREAMING")
    .then(() -> async.completed())
    .verify();
  }

  function testBindWs(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onText("LOOP,0");
    })
    .await("ws.dispose")
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTED:WS-STREAMING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("bind_session\r\nLS_session=sid&LS_keepalive_millis=5000&LS_send_sync=false&LS_cause=ws.loop")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> {
      page.freeze();
    })
    .await("control\r\nLS_reqId=1&LS_op=destroy&LS_close_socket=true&LS_cause=page.frozen")
    .await("ws.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=page.frozen")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:WS-STREAMING")
    .then(() -> async.completed())
    .verify();
  }

  function testBindWsPolling(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("WS-POLLING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTED:STREAM-SENSING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .then(() -> {
      ws.onText("WSOK");
    })
    .await("bind_session\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=19000&LS_cause=http.loop")
    .then(() -> {
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> {
      page.freeze();
    })
    .await("CONNECTED:WS-POLLING")
    .await("control\r\nLS_reqId=1&LS_op=destroy&LS_close_socket=true&LS_cause=page.frozen")
    .await("ws.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_cause=page.frozen")
    .await("CONNECTING")
    .then(() -> {
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:STREAM-SENSING")
    .then(() -> async.completed())
    .verify();
  }

  function testCreateHttp(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("HTTP");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> {
      page.freeze();
    })
    .await("CONNECTED:STREAM-SENSING")
    .await("http.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_cause=page.frozen")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:STREAM-SENSING")
    .then(() -> async.completed())
    .verify();
  }

  function testBindHttp(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("HTTP-STREAMING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("CONNECTED:STREAM-SENSING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> {
      page.freeze();
    })
    .await("CONNECTED:HTTP-STREAMING")
    .await("http.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_cause=page.frozen")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:STREAM-SENSING")
    .then(() -> async.completed())
    .verify();
  }

  function testBindHttpPolling(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("HTTP-POLLING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=19000&LS_cause=http.loop")
    .await("CONNECTED:STREAM-SENSING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> {
      page.freeze();
    })
    .await("CONNECTED:HTTP-POLLING")
    .await("http.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_cause=page.frozen")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:STREAM-SENSING")
    .then(() -> async.completed())
    .verify();
  }

  function testRecovery(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .await("CONNECTED:WS-STREAMING")
    .await("DISCONNECTED:TRYING-RECOVERY")
    .then(() -> {
      page.freeze();
    })
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=page.frozen")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:WS-STREAMING")
    .then(() -> async.completed())
    .verify();
  }

  function testWhileRetrying(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setSessionRecoveryTimeout(0);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .await("CONNECTED:WS-STREAMING")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.freeze();
    })
    .then(() -> {
      page.resume();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=page.frozen")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:WS-STREAMING")
    .then(() -> async.completed())
    .verify();
  }

  function testCreateTTL(async: utest.Async) {
    exps
    .then(() -> {
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONERR,5,server busy");
    })
    .await("ws.dispose")
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_ttl_millis=unlimited&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=ws.conerr.5")
    .await("DISCONNECTED:WILL-RETRY")
    .await("CONNECTING")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> {
      page.freeze();
    })
    .await("CONNECTED:STREAM-SENSING")
    .await("http.dispose")
    .await("DISCONNECTED:WILL-RETRY")
    .then(() -> {
      page.resume();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=page.frozen")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:WS-STREAMING")
    .then(() -> async.completed())
    .verify();
  }

  function testWhileDisconnected(async: utest.Async) {
    exps
    .then(() -> {
      page.frozen = true;
    })
    .then(() -> {
      client.connect();
    })
    .then(() -> {
      page.resume();
    })
    .await("ws.init http://server/lightstreamer")
    .await("CONNECTING")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=page.frozen")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("CONNECTED:WS-STREAMING")
    .then(() -> async.completed())
    .verify();
  }
}