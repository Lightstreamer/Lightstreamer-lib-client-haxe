/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener.BaseSubscriptionListener;
import com.lightstreamer.client.BaseListener.BaseMessageListener;
import com.lightstreamer.client.BaseListener.BaseClientListener;

class TestRecovery extends utest.Test {
  var ws: MockWsClient;
  var http: MockHttpClient;
  var ctrl: MockHttpClient;
  var scheduler: MockScheduler;
  var client: LightstreamerClient;
  var listener: BaseClientListener;
  var msgListener: BaseMessageListener;
  var subListener: BaseSubscriptionListener;

  function setup() {
    ws = new MockWsClient(this);
    http = new MockHttpClient(this);
    ctrl = new MockHttpClient(this, "ctrl");
    scheduler = new MockScheduler(this);
    client = new LightstreamerClient("http://server", "TEST", new TestFactory(this, ws, http, ctrl, scheduler));
    listener = new BaseClientListener();
    msgListener = new BaseMessageListener();
    subListener = new BaseSubscriptionListener();
  }

  function teardown() {
    client.disconnect();
  }

  function testCreateWS(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("bind_session\r\nLS_session=sid&LS_keepalive_millis=5000&LS_send_sync=false&LS_cause=recovery.loop")
    .then(() -> {
      equals("DISCONNECTED:TRYING-RECOVERY", client.getStatus());
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> async.completed())
    .verify();
  }

  function testBindWS(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onText("LOOP,0");
    })
    .await("ws.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("bind_session\r\nLS_session=sid&LS_keepalive_millis=5000&LS_send_sync=false&LS_cause=ws.loop")
    .then(() -> {
      ws.onText("WSOK");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("bind_session\r\nLS_session=sid&LS_keepalive_millis=5000&LS_send_sync=false&LS_cause=recovery.loop")
    .then(() -> {
      equals("DISCONNECTED:TRYING-RECOVERY", client.getStatus());
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> async.completed())
    .verify();
  }

  function testBindWSPolling(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("WS-POLLING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .then(() -> ws.onText("WSOK"))
    .await("bind_session\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=19000&LS_cause=http.loop")
    .then(() -> {
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .then(() -> ws.onText("WSOK"))
    .await("bind_session\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=5000&LS_cause=recovery.loop")
    .then(() -> {
      equals("DISCONNECTED:TRYING-RECOVERY", client.getStatus());
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> async.completed())
    .verify();
  }

  function testBindHTTP(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("HTTP");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onError();
    })
    .await("http.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=http.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_keepalive_millis=5000&LS_send_sync=false&LS_cause=recovery.loop")
    .then(() -> {
      equals("DISCONNECTED:TRYING-RECOVERY", client.getStatus());
      http.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> async.completed())
    .verify();
  }

  function testBindHTTPPolling(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setForcedTransport("HTTP-POLLING");
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=19000&LS_cause=http.loop")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onError();
    })
    .await("http.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=http.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_polling=true&LS_polling_millis=0&LS_idle_millis=5000&LS_cause=recovery.loop")
    .then(() -> {
      equals("DISCONNECTED:TRYING-RECOVERY", client.getStatus());
      http.onText("CONOK,sid,70000,5000,*");
    })
    .then(() -> async.completed())
    .verify();
  }

  function testPROG_Mismatch(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("PROG,100");
    })
    .await("http.dispose")
    .then(() -> {
      equals("DISCONNECTED:WILL-RETRY", client.getStatus());
      scheduler.fireRetryTimeout();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=prog.mismatch.100.0")
    .then(() -> equals("CONNECTING", client.getStatus()))
    .then(() -> async.completed())
    .verify();
  }

  function testMSGDONE(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      client._sendMessage("foo", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .then(() -> {
      ws.onText("MSGDONE,*,1,");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=1&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGDONE_InRecovery(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      msgListener._onProcessed = (msg, resp) -> exps.signal('onProcessed $msg');
      client._sendMessage("foo", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .then(() -> {
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("PROG,0");
      http.onText("MSGDONE,*,1,");
    })
    .await("onProcessed foo")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGDONE_Skip(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      msgListener._onProcessed = (msg, resp) -> exps.signal('onProcessed $msg');
      client._sendMessage("foo", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .then(() -> ws.onText("MSGDONE,*,1,"))
    .await("onProcessed foo")
    .then(() -> ws.onError())
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=1&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("PROG,0");
      http.onText("MSGDONE,*,1,");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGFAIL(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      client._sendMessage("foo", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .then(() -> {
      ws.onText("MSGFAIL,*,1,10,error");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=1&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGFAIL_InRecovery(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      msgListener._onError = msg -> exps.signal('onError $msg');
      client._sendMessage("foo", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .then(() -> {
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("PROG,0");
      ws.onText("MSGFAIL,*,1,10,error");
    })
    .await("onError foo")
    .then(() -> async.completed())
    .verify();
  }

  function testMSGFAIL_Skip(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      msgListener._onError = msg -> exps.signal('onError $msg');
      client._sendMessage("foo", msgListener);
    })
    .await("msg\r\nLS_reqId=1&LS_message=foo&LS_msg_prog=1")
    .then(() -> ws.onText("MSGFAIL,*,1,10,error"))
    .await("onError foo")
    .then(() -> ws.onError())
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=1&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("PROG,0");
      http.onText("MSGFAIL,*,1,10,error");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }

  function testSubscribe(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      var sub = new Subscription("DISTINCT", ["itm"], ["fld"]);
      sub.addListener(subListener);
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=itm&LS_schema=fld&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,1");
      ws.onText("U,1,1,a");
      ws.onText("EOS,1,1");
      ws.onText("CS,1,1");
      ws.onText("OV,1,1,1");
      ws.onText("CONF,1,unlimited,unfiltered");
      ws.onText("UNSUB,1");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=7&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> async.completed())
    .verify();
  }

  function testSubscribe_InRecovery(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      var sub = new Subscription("DISTINCT", ["itm"], ["fld"]);
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onItemUpdate = update -> exps.signal("onItemUpdate");
      subListener._onEndOfSnapshot = (itemName, itemPos) -> exps.signal("onEndOfSnapshot");
      subListener._onClearSnapshot = (itemName, itemPos) -> exps.signal("onClearSnapshot");
      subListener._onItemLostUpdates = (itemName, itemPos, lostUpdates) -> exps.signal("onItemLostUpdates");
      subListener._onRealMaxFrequency = frequency -> exps.signal("onRealMaxFrequency");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      sub.addListener(subListener);
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=itm&LS_schema=fld&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("PROG,0");
      ws.onText("SUBOK,1,1,1");
      ws.onText("U,1,1,a");
      ws.onText("EOS,1,1");
      ws.onText("CS,1,1");
      ws.onText("OV,1,1,1");
      ws.onText("CONF,1,unlimited,unfiltered");
      ws.onText("UNSUB,1");
    })
    .await("onSubscription")
    .await("onItemUpdate")
    .await("onEndOfSnapshot")
    .await("onClearSnapshot")
    .await("onItemLostUpdates")
    .await("onRealMaxFrequency")
    .await("onUnsubscription")
    .then(() -> async.completed())
    .verify();
  }

  function testSubscribe_Skip(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      var sub = new Subscription("DISTINCT", ["itm"], ["fld"]);
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onItemUpdate = update -> exps.signal("onItemUpdate");
      subListener._onEndOfSnapshot = (itemName, itemPos) -> exps.signal("onEndOfSnapshot");
      subListener._onClearSnapshot = (itemName, itemPos) -> exps.signal("onClearSnapshot");
      subListener._onItemLostUpdates = (itemName, itemPos, lostUpdates) -> exps.signal("onItemLostUpdates");
      subListener._onRealMaxFrequency = frequency -> exps.signal("onRealMaxFrequency");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      sub.addListener(subListener);
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=itm&LS_schema=fld&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,1");
      ws.onText("U,1,1,a");
      ws.onText("EOS,1,1");
      ws.onText("CS,1,1");
      ws.onText("OV,1,1,1");
      ws.onText("CONF,1,unlimited,unfiltered");
      ws.onText("UNSUB,1");
    })
    .await("onSubscription")
    .await("onItemUpdate")
    .await("onEndOfSnapshot")
    .await("onClearSnapshot")
    .await("onItemLostUpdates")
    .await("onRealMaxFrequency")
    .await("onUnsubscription")
    .then(() -> ws.onError())
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=7&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("PROG,0");
      ws.onText("SUBOK,1,1,1");
      ws.onText("U,1,1,a");
      ws.onText("EOS,1,1");
      ws.onText("CS,1,1");
      ws.onText("OV,1,1,1");
      ws.onText("CONF,1,unlimited,unfiltered");
      ws.onText("UNSUB,1");
      ws.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> async.completed())
    .verify();
  }

  function testTransportTimeout(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      scheduler.fireTransportTimeout();
      scheduler.fireRetryTimeout();
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=recovery.error")
    .then(() -> async.completed())
    .verify();
  }

  function testTransportError(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onError();
      scheduler.fireRetryTimeout();
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=recovery.error")
    .then(() -> async.completed())
    .verify();
  }

  function testRecoveryTimeout(async: utest.Async) {
    exps
    .then(() -> {
      // set a low timeout so that the condition on the transition check.recovery.timeout fails immediately
      client.connectionOptions.setSessionRecoveryTimeout(1_000);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      equals("DISCONNECTED:TRYING-RECOVERY", client.getStatus());
      scheduler.fireTransportTimeout();
    })
    .await("http.dispose")
    .then(() -> {
      equals("DISCONNECTED:WILL-RETRY", client.getStatus());
      scheduler.fireRetryTimeout();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=recovery.timeout")
    .then(() -> async.completed())
    .verify();
  }

  function testCONERR_Retry(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("CONERR,4,error");
      scheduler.fireRetryTimeout();
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=recovery.conerr.4")
    .then(() -> async.completed())
    .verify();
  }

  function testEND_Retry(async: utest.Async) {
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
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onError();
    })
    .await("ws.dispose")
    .then(() -> scheduler.fireRecoveryTimeout())
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_recovery_from=0&LS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_cause=ws.error")
    .then(() -> {
      http.onText("END,41,error");
      scheduler.fireRetryTimeout();
    })
    .await("http.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=recovery.end.41")
    .then(() -> async.completed())
    .verify();
  }
}