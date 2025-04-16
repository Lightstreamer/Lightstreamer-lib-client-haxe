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
package com.lightstreamer.client.mpn;

import com.lightstreamer.client.internal.MpnClientMachine;
import com.lightstreamer.internal.NativeTypes.Long;

private class BaseMpnListener implements MpnDeviceListener {
  public function new() {}
  public function onListenStart(): Void {}
  public function onListenEnd(): Void {}
  public function onRegistered(): Void {}
  public function onSuspended(): Void {}
  public function onResumed(): Void {}
  dynamic public function _onStatusChanged(status: String) {}
  public function onStatusChanged(status: String, timestamp: Long): Void _onStatusChanged(status);
  public function onRegistrationFailed(code: Int, message: String): Void {}
  dynamic public function _onSubscriptionsUpdated() {}
  public function onSubscriptionsUpdated(): Void _onSubscriptionsUpdated();
}

class TestMpnSubscribe extends utest.Test {
  var client: LightstreamerClient;
  var ws: MockWsClient;
  var http: MockHttpClient;
  var ctrl: MockHttpClient;
  var scheduler: MockScheduler;
  var device: MpnDevice;

  function setup() {
    ws = new MockWsClient(this);
    http = new MockHttpClient(this);
    ctrl = new MockHttpClient(this, "ctrl");
    scheduler = new MockScheduler(this);
    client = new LightstreamerClient("http://server", "TEST", new TestFactory(this, ws, http, ctrl, scheduler));
    var listener = new BaseMpnListener();
    listener._onSubscriptionsUpdated = () -> exps.signal("onSubscriptionsUpdated");
    #if js
    device = new MpnDevice("tok", "com.example.testapp", "Google");
    #end
    #if java
    device = new MpnDevice(utils.AndroidTools.appContext, "tok");
    #end
    device.addListener(listener);
  }

  function teardown() {
    client.disconnect();
    #if js
    js.Browser.getLocalStorage().clear();
    #end
  }
  
  function testSnapshotIsEmpty(async: utest.Async) {
    exps
    .then(() -> {    
      client.registerForMpn(device);
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
    .await("control\r\nLS_reqId=1&LS_op=register&PN_type=Google&PN_appId=com.example.testapp&PN_deviceToken=tok")
    .then(() -> {
      ws.onText("MPNREG,devid,adapter");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=DEV-devid&LS_schema=status%20status_timestamp&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=2&LS_mode=COMMAND&LS_group=SUBS-devid&LS_schema=key%20command&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,2,1,2,1,2");
      ws.onText("EOS,2,1");
    })
    .await("onSubscriptionsUpdated")
    .then(() -> async.completed())
    .verify();
  }

  function testSnapshotHasOneItem(async: utest.Async) {
    exps
    .then(() -> {    
      client.registerForMpn(device);
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
    .await("control\r\nLS_reqId=1&LS_op=register&PN_type=Google&PN_appId=com.example.testapp&PN_deviceToken=tok")
    .then(() -> {
      ws.onText("MPNREG,devid,adapter");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=DEV-devid&LS_schema=status%20status_timestamp&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=2&LS_mode=COMMAND&LS_group=SUBS-devid&LS_schema=key%20command&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,2,1,2,1,2");
      ws.onText("U,2,1,SUB-sub3|ADD");
    })
    .await("control\r\nLS_reqId=4&LS_op=add&LS_subId=3&LS_mode=MERGE&LS_group=SUB-sub3&LS_schema=status%20status_timestamp%20notification_format%20trigger%20group%20schema%20adapter%20mode%20requested_buffer_size%20requested_max_frequency&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .then(() -> {
      ws.onText("EOS,2,1");
      ws.onText("SUBOK,3,1,10");
      ws.onText("U,3,1,ACTIVE|100|fmt|trg|i1|f1|adt|MERGE|unlimited|unlimited");
    })
    .await("onSubscriptionsUpdated")
    .then(() -> {
      var ls = client.getMpnSubscriptions(null).toHaxe();
      equals(1, ls.length);
      var sub = ls[0];
      equals("fmt", sub.getActualNotificationFormat());
      equals("trg", sub.getActualTriggerExpression());
      equals("i1", sub.getItemGroup());
      equals("f1", sub.getFieldSchema());
      equals("adt", sub.getDataAdapter());
      equals("MERGE", sub.getMode());
      equals("unlimited", sub.getRequestedMaxFrequency());
      equals("unlimited", sub.getRequestedBufferSize());
    })
    .then(() -> async.completed())
    .verify();
  }

  function testEarlyDeletion(async: utest.Async) {
    exps
    .then(() -> {    
      client.registerForMpn(device);
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
    .await("control\r\nLS_reqId=1&LS_op=register&PN_type=Google&PN_appId=com.example.testapp&PN_deviceToken=tok")
    .then(() -> {
      ws.onText("MPNREG,devid,adapter");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=DEV-devid&LS_schema=status%20status_timestamp&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=2&LS_mode=COMMAND&LS_group=SUBS-devid&LS_schema=key%20command&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,2,1,2,1,2");
      ws.onText("U,2,1,SUB-sub3|ADD");
    })
    .await("control\r\nLS_reqId=4&LS_op=add&LS_subId=3&LS_mode=MERGE&LS_group=SUB-sub3&LS_schema=status%20status_timestamp%20notification_format%20trigger%20group%20schema%20adapter%20mode%20requested_buffer_size%20requested_max_frequency&LS_data_adapter=adapter&LS_snapshot=true&LS_requested_max_frequency=unfiltered&LS_ack=false")
    .then(() -> {
      ws.onText("EOS,2,1");
      ws.onText("U,2,1,SUB-sub3|DELETE");
    })
    .await("onSubscriptionsUpdated")
    .then(() -> {
      var ls = client.getMpnSubscriptions(null).toHaxe();
      equals(0, ls.length);
    })
    .then(() -> async.completed())
    .verify();
  }
}