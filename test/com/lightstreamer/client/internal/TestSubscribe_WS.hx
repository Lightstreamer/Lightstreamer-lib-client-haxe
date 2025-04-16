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
package com.lightstreamer.client.internal;

import com.lightstreamer.client.BaseListener.BaseSubscriptionListener;
import com.lightstreamer.client.BaseListener.BaseClientListener;

class TestSubscribe_WS extends utest.Test {
  var client: LightstreamerClient;
  var listener: BaseClientListener;
  var subListener: BaseSubscriptionListener;
  var ws: MockWsClient;
  var http: MockHttpClient;
  var ctrl: MockHttpClient;
  var scheduler: MockScheduler;
  var sub: Subscription;

  function setup() {
    ws = new MockWsClient(this);
    http = new MockHttpClient(this);
    ctrl = new MockHttpClient(this, "ctrl");
    scheduler = new MockScheduler(this);
    listener = new BaseClientListener();
    client = new LightstreamerClient("http://server", "TEST", new TestFactory(this, ws, http, ctrl, scheduler));
    client.addListener(listener);
    subListener = new BaseSubscriptionListener();
    sub = new Subscription("DISTINCT", ["item"], ["f1", "f2"]);
    sub.setRequestedSnapshot("no");
    sub.addListener(subListener);
  }

  function teardown() {
    client.disconnect();
  }
  
  function testSubscribe(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> async.completed())
    .verify();
  }

  function testSubscribeFieldWithPlus(async: utest.Async) {
    exps
    .then(() -> {
      sub.setFields(["f1+f2"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%2Bf2&LS_snapshot=false&LS_ack=false")
    .then(() -> async.completed())
    .verify();
  }

  function testREQERR(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscriptionError = (code, msg) -> exps.signal('onError $code $msg');
      client.subscribe(sub);
      isTrue(sub.isActive());
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("REQERR,1,-5,error"))
    .await("onError -5 error")
    .then(() -> isFalse(sub.isActive()))
    .then(() -> async.completed())
    .verify();
  }

  function testSUBOK(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,1,2"))
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> async.completed())
    .verify();
  }

  function testSUBOK_CountMismatch(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscriptionError = (code, msg) -> exps.signal('onError $code $msg');
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,10,2"))
    .await(
      "onError 61 Expected 1 items but got 10", 
      "control\r\nLS_reqId=2&LS_subId=1&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=2&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,2,1,20"))
    .await(
      "onError 61 Expected 2 fields but got 20", 
      "control\r\nLS_reqId=4&LS_subId=2&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=5&LS_op=add&LS_subId=3&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("REQOK,5"))
    .then(() -> ws.onText("SUBOK,3,10,2"))
    .await(
      "onError 61 Expected 1 items but got 10", 
      "control\r\nLS_reqId=6&LS_subId=3&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=7&LS_op=add&LS_subId=4&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("REQOK,7"))
    .then(() -> ws.onText("SUBOK,4,1,20"))
    .await(
      "onError 61 Expected 2 fields but got 20", 
      "control\r\nLS_reqId=8&LS_subId=4&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
    })
    .then(() -> async.completed())
    .verify();
  }

  function testSUBOK_ItemGroupAndFieldSchema(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      sub.setItemGroup("ig");
      sub.setFieldSchema("fs");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=ig&LS_schema=fs&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,10,20"))
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> async.completed())
    .verify();
  }

  function testSUBCMD(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["item"], ["key", "command"]);
      sub.addListener(subListener);
      subListener._onSubscription = () -> exps.signal("onSubscription");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=item&LS_schema=key%20command&LS_snapshot=true&LS_ack=false")
    .then(() -> ws.onText("SUBCMD,1,1,2,1,2"))
    .await("onSubscription")
    .then(() -> {
      isTrue(sub.isSubscribed());
      equals(1, sub.getKeyPosition());
      equals(2, sub.getCommandPosition());
    })
    .then(() -> async.completed())
    .verify();
  }

  function testSUBCMD_CountMismatch(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["item"], ["key", "command"]);
      sub.addListener(subListener);
      subListener._onSubscriptionError = (code, msg) -> exps.signal('onError $code $msg');
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=item&LS_schema=key%20command&LS_snapshot=true&LS_ack=false")
    .then(() -> ws.onText("SUBCMD,1,10,2,1,2"))
    .await(
      "onError 61 Expected 1 items but got 10", 
      "control\r\nLS_reqId=2&LS_subId=1&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=2&LS_mode=COMMAND&LS_group=item&LS_schema=key%20command&LS_snapshot=true&LS_ack=false")
    .then(() -> ws.onText("SUBCMD,2,1,20,1,2"))
    .await(
      "onError 61 Expected 2 fields but got 20", 
      "control\r\nLS_reqId=4&LS_subId=2&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=5&LS_op=add&LS_subId=3&LS_mode=COMMAND&LS_group=item&LS_schema=key%20command&LS_snapshot=true&LS_ack=false")
    .then(() -> ws.onText("REQOK,5"))
    .then(() -> ws.onText("SUBCMD,3,10,2,1,2"))
    .await(
      "onError 61 Expected 1 items but got 10", 
      "control\r\nLS_reqId=6&LS_subId=3&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
      client.subscribe(sub);
    })
    .await("control\r\nLS_reqId=7&LS_op=add&LS_subId=4&LS_mode=COMMAND&LS_group=item&LS_schema=key%20command&LS_snapshot=true&LS_ack=false")
    .then(() -> ws.onText("REQOK,7"))
    .then(() -> ws.onText("SUBCMD,4,1,20,1,2"))
    .await(
      "onError 61 Expected 2 fields but got 20", 
      "control\r\nLS_reqId=8&LS_subId=4&LS_op=delete&LS_ack=false")
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
    })
    .then(() -> async.completed())
    .verify();
  }

  function testCONF(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onRealMaxFrequency = freq -> exps.signal('onRealMaxFrequency $freq');
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,2");
      ws.onText("CONF,1,unlimited,filtered");
    })
    .await("onRealMaxFrequency unlimited")
    .then(() -> async.completed())
    .verify();
  }

  function testU(async: utest.Async) {
    var lastUpdate;
    exps
    .then(() -> {
      subListener._onItemUpdate = update -> {
        lastUpdate = update;
        exps.signal("onItemUpdate");
      };
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,2");
      ws.onText("U,1,1,a|b");
    })
    .await("onItemUpdate")
    .then(() -> {
      equals(1, lastUpdate.getItemPos());
      equals("item", lastUpdate.getItemName());
      equals("a", lastUpdate.getValue(1));
      equals("b", lastUpdate.getValue(2));
      equals("a", lastUpdate.getValue("f1"));
      equals("b", lastUpdate.getValue("f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testEOS(async: utest.Async) {
    var lastUpdate;
    exps
    .then(() -> {
      subListener._onItemUpdate = update -> {
        lastUpdate = update;
        exps.signal("onItemUpdate");
      };
      subListener._onEndOfSnapshot = (name, pos) -> exps.signal('onEndOfSnapshot $name $pos');
      sub.setRequestedSnapshot("yes");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,2");
      ws.onText("U,1,1,a|b");
    })
    .await("onItemUpdate")
    .then(() -> isTrue(lastUpdate.isSnapshot()))
    .then(() ->  ws.onText("EOS,1,1"))
    .await("onEndOfSnapshot item 1")
    .then(() -> ws.onText("U,1,1,a|b"))
    .await("onItemUpdate")
    .then(() -> isFalse(lastUpdate.isSnapshot()))
    .then(() -> async.completed())
    .verify();
  }

  function testCS(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onClearSnapshot = (name, pos) -> exps.signal('onClearSnapshot $name $pos');
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,2");
      ws.onText("CS,1,1");
    })
    .await("onClearSnapshot item 1")
    .then(() -> async.completed())
    .verify();
  }

  function testOV(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onItemLostUpdates = (name, pos, losts) -> exps.signal('onItemLostUpdates $name $pos $losts');
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,2");
      ws.onText("OV,1,1,33");
    })
    .await("onItemLostUpdates item 1 33")
    .then(() -> async.completed())
    .verify();
  }

  function testSUBOK_Abort(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,1,2"))
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> client.disconnect())
    .await("control\r\nLS_reqId=2&LS_op=destroy&LS_close_socket=true&LS_cause=api")
    .await("ws.dispose")
    .await("onUnsubscription")
    .then(() -> isFalse(sub.isSubscribed()))
    .then(() -> async.completed())
    .verify();
  }

  function testUNSUB(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,1,2"))
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> ws.onText("UNSUB,1"))
    .await("onUnsubscription")
    .then(() -> isFalse(sub.isSubscribed()))
    .then(() -> async.completed())
    .verify();
  }

  function testUnsubscribe(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,1,2"))
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> client.unsubscribe(sub))
    .await("onUnsubscription", "control\r\nLS_reqId=2&LS_subId=1&LS_op=delete&LS_ack=false")
    .then(() -> isFalse(sub.isSubscribed()))
    .then(() -> async.completed())
    .verify();
  }

  function testReconf(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,1,2"))
    .await("onSubscription")
    .then(() -> sub.setRequestedMaxFrequency("12.3"))
    .await("control\r\nLS_reqId=2&LS_subId=1&LS_op=reconf&LS_requested_max_frequency=12.3")
    .then(() -> async.completed())
    .verify();
  }

  function testReconf_Twice(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> ws.onText("SUBOK,1,1,2"))
    .await("onSubscription")
    .then(() -> sub.setRequestedMaxFrequency("12.3"))
    .then(() -> sub.setRequestedMaxFrequency("unlimited"))
    .await("control\r\nLS_reqId=2&LS_subId=1&LS_op=reconf&LS_requested_max_frequency=12.3")
    .then(() -> ws.onText("REQOK,2"))
    .await("control\r\nLS_reqId=3&LS_subId=1&LS_op=reconf&LS_requested_max_frequency=unlimited")
    .then(() -> async.completed())
    .verify();
  }

  function testSUBOK_Zombie(async: utest.Async) {
    exps
    .then(() -> client.connect())
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
      ws.onText("SUBOK,1,1,2");
    })
    .await("control\r\nLS_reqId=1&LS_subId=1&LS_op=delete&LS_ack=false&LS_cause=zombie")
    .then(() -> async.completed())
    .verify();
  }

  function testSubscribeAgainAfterSessionError(async: utest.Async) {
    exps
    .then(() -> {
      client.connectionOptions.setSessionRecoveryTimeout(0);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onError();
      scheduler.fireRetryTimeout();
    })
    .await("ws.dispose")
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_send_sync=false&LS_cause=ws.error")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> async.completed())
    .verify();
  }

  /**
   * Test that the unsubscriptions made in a session don't leak in the next session.
   */
  function testUnsubscriptionLeaking(async: utest.Async) {
    var sub2 = new Subscription("DISTINCT", ["item"], ["f1", "f2"]);
    sub2.setRequestedSnapshot("no");
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      client.subscribe(sub);
      client.subscribe(sub2);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("SUBOK,1,1,2");
    })
    .await("onSubscription")
    .then(() -> {
      client.unsubscribe(sub);
      client.unsubscribe(sub2);
    })
    .await("control\r\nLS_reqId=3&LS_subId=1&LS_op=delete&LS_ack=false")
    .await("control\r\nLS_reqId=4&LS_subId=2&LS_op=delete&LS_ack=false")
    .then(() -> {
      equals(0, client.getSubscriptions().toHaxe().length);
      client.disconnect();
    })
    .await("control\r\nLS_reqId=5&LS_op=destroy&LS_close_socket=true&LS_cause=api")
    .await("ws.dispose")
    .then(() -> client.connect())
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
      client.connectionOptions.setRequestedMaxBandwidth("1000");
    })
    .await("control\r\nLS_reqId=6&LS_op=constrain&LS_requested_max_bandwidth=1000")
    .then(() -> async.completed())
    .verify();
  }
}