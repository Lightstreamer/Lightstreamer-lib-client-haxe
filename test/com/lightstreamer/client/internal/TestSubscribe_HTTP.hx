package com.lightstreamer.client.internal;

import com.lightstreamer.client.BaseListener.BaseSubscriptionListener;
import com.lightstreamer.client.BaseListener.BaseClientListener;

class TestSubscribe_HTTP extends utest.Test {
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
    client = new LightstreamerClient("http://server", "TEST", ws.create, http.create, ctrl.create, scheduler.create);
    client.connectionOptions.setForcedTransport("HTTP-STREAMING");
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQERR,1,-5,error");
      ctrl.onDone();
    })
    .await("onError -5 error", "ctrl.dispose")
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
    })
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,20");
    })
    .await(
      "onError 61 Expected 2 fields but got 20", 
      "ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=2&LS_subId=1&LS_op=delete")
    .then(() -> {
      ctrl.onText("REQOK,2");
      ctrl.onDone();
    })
    .then(() -> {
      isFalse(sub.isSubscribed());
      equals([], client.getSubscriptions().toHaxe());
    })
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=item&LS_schema=key%20command&LS_snapshot=true")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBCMD,1,1,2,1,2");
    })
    .await("onSubscription")
    .then(() -> {
      isTrue(sub.isSubscribed());
      equals(1, sub.getKeyPosition());
      equals(2, sub.getCommandPosition());
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
      http.onText("CONF,1,unlimited,filtered");
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
      http.onText("U,1,1,a|b");
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=true")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
      http.onText("U,1,1,a|b");
    })
    .await("onItemUpdate")
    .then(() -> isTrue(lastUpdate.isSnapshot()))
    .then(() -> http.onText("EOS,1,1"))
    .await("onEndOfSnapshot item 1")
    .then(() -> http.onText("U,1,1,a|b"))
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
      http.onText("CS,1,1");
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
      http.onText("OV,1,1,33");
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
    })
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> client.disconnect())
    .await("http.dispose")
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
    })
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> http.onText("UNSUB,1"))
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
    })
    .await("onSubscription")
    .then(() -> isTrue(sub.isSubscribed()))
    .then(() -> client.unsubscribe(sub))
    .await("onUnsubscription", "ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=2&LS_subId=1&LS_op=delete")
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
    })
    .await("onSubscription")
    .then(() -> sub.setRequestedMaxFrequency("12.3"))
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=2&LS_subId=1&LS_op=reconf&LS_requested_max_frequency=12.3")
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
    })
    .await("onSubscription")
    .then(() -> sub.setRequestedMaxFrequency("12.3"))
    .then(() -> sub.setRequestedMaxFrequency("unlimited"))
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=2&LS_subId=1&LS_op=reconf&LS_requested_max_frequency=12.3")
    .then(() -> {
      ctrl.onText("REQOK,2");
      ctrl.onDone();
    })
    .await("ctrl.dispose")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=3&LS_subId=1&LS_op=reconf&LS_requested_max_frequency=unlimited")
    .then(() -> async.completed())
    .verify();
  }

  function testSUBOK_Zombie(async: utest.Async) {
    exps
    .then(() -> client.connect())
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("SUBOK,1,1,2");
    })
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_subId=1&LS_op=delete&LS_cause=zombie")
    .then(() -> async.completed())
    .verify();
  }

  function testCtrlTimeout(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> scheduler.fireCtrlTimeout())
    .await("ctrl.dispose")
    .then(() -> scheduler.fireCtrlTimeout())
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=2&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> async.completed())
    .verify();
  }

  function testCtrlError(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> ctrl.onError())
    .await("ctrl.dispose")
    .then(() -> scheduler.fireCtrlTimeout())
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=2&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> async.completed())
    .verify();
  }

  function testREQOK_CtrlError(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      ctrl.onText("REQOK,1");
      ctrl.onError();
    })
    .await("ctrl.dispose")
    //.then(() -> scheduler.fireCtrlTimeout())
    // NB client doesn't resend the request
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
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_cause=api")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> {
      http.onError();
      scheduler.fireRetryTimeout();
    })
    .await("http.dispose")
    .await("ctrl.dispose")
    .await("http.send http://server/lightstreamer/create_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_polling=true&LS_polling_millis=0&LS_idle_millis=0&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_old_session=sid&LS_cause=http.error")
    .then(() -> {
      http.onText("CONOK,sid,70000,5000,*");
      http.onText("LOOP,0");
    })
    .await("http.dispose")
    .await("http.send http://server/lightstreamer/bind_session.txt?LS_protocol=TLCP-2.5.0\r\nLS_session=sid&LS_content_length=50000000&LS_send_sync=false&LS_cause=http.loop")
    .await("ctrl.send http://server/lightstreamer/control.txt?LS_protocol=TLCP-2.5.0&LS_session=sid\r\nLS_reqId=2&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=item&LS_schema=f1%20f2&LS_snapshot=false")
    .then(() -> async.completed())
    .verify();
  }
}