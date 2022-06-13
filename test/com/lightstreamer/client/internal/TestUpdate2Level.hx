package com.lightstreamer.client.internal;

import com.lightstreamer.client.BaseListener.BaseSubscriptionListener;

class TestUpdate2Level extends utest.Test {
  var client: LightstreamerClient;
  var subListener: BaseSubscriptionListener;
  var ws: MockWsClient;
  var sub: Subscription;
  var updates: Array<ItemUpdate>;

  function setup() {
    ws = new MockWsClient(this);
    subListener = new BaseSubscriptionListener();
    subListener._onItemUpdate = update -> {
      updates.push(update);
      exps.signal("onItemUpdate");
    };
    subListener._onRealMaxFrequency = freq -> exps.signal('onRealMaxFrequency $freq');
    subListener._onItemLostUpdates = (name, pos, losts) -> exps.signal('onItemLostUpdates $name $pos $losts');
    subListener._onCommandSecondLevelItemLostUpdates = (losts, key) -> exps.signal('onCommandSecondLevelItemLostUpdates $losts $key');
    subListener._onEndOfSnapshot = (name, pos) -> exps.signal('onEndOfSnapshot $name $pos');
    subListener._onCommandSecondLevelSubscriptionError = (code, message, key) -> exps.signal('on2LevelError $code $message $key');
    subListener._onClearSnapshot = (name, pos) -> exps.signal('onClearSnapshot $name $pos');
    client = new LightstreamerClient("http://server", "TEST", ws.create);
    sub = new Subscription("COMMAND", ["i1", "i2"], ["f1", "f2", "key", "command"]);
    sub.setCommandSecondLevelFields(["f3", "f4"]);
    sub.setRequestedSnapshot("no");
    sub.addListener(subListener);
    updates = [];
  }

  function teardown() {
    client.disconnect();
  }

  function testADD(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(1, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      strictEquals("a", sub.getValue(1, 1));
      strictEquals("b", sub.getValue(1, 2));
      strictEquals("a", sub.getValue(1, "f1"));
      strictEquals("b", sub.getValue(1, "f2"));
      strictEquals("a", sub.getValue("i1", 1));
      strictEquals("b", sub.getValue("i1", 2));
      strictEquals("a", sub.getValue("i1", "f1"));
      strictEquals("b", sub.getValue("i1", "f2"));
      strictEquals("a", sub.getCommandValue(1, "item1", 1));
      strictEquals("b", sub.getCommandValue(1, "item1", 2));
      strictEquals("a", sub.getCommandValue(1, "item1", "f1"));
      strictEquals("b", sub.getCommandValue(1, "item1", "f2"));
      strictEquals("a", sub.getCommandValue("i1", "item1", 1));
      strictEquals("b", sub.getCommandValue("i1", "item1", 2));
      strictEquals("a", sub.getCommandValue("i1", "item1", "f1"));
      strictEquals("b", sub.getCommandValue("i1", "item1", "f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testEarlyUPD(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|UPDATE");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(1, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testEarlyDEL(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|DELETE");
    })
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(1, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"item1","command"=>"DELETE"], u.getChangedFields());
      strictEquals([1=>null,2=>null,3=>"item1",4=>"DELETE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"item1","command"=>"DELETE"], u.getFields());
      strictEquals([1=>null,2=>null,3=>"item1",4=>"DELETE"], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals(null, u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("DELETE", u.getValue(4));
      strictEquals(null, u.getValue("f1"));
      strictEquals(null, u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("DELETE", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testADD_BadItemName(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|123|ADD");
    })
    .await("onItemUpdate")
    .await("on2LevelError 14 The received key value is not a valid name for an Item 123")
    .then(() -> {
      strictEquals(1, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"123","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"123",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"123","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"123",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("123", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("123", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testADD_REQERR(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("REQERR,2,-5,error");  
    })
    .await("on2LevelError -5 error item1")
    .then(() -> {
      strictEquals(1, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testADD_UPD1Level_UPD2Level(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("U,2,1,c|d");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals(null, u.getValue(5));
      strictEquals(null, u.getValue(6));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(null, u.getValue("f5"));
      strictEquals(null, u.getValue("f6"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(false, u.isValueChanged(5));
      strictEquals(false, u.isValueChanged(6));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      strictEquals(false, u.isValueChanged("f5"));
      strictEquals(false, u.isValueChanged("f6"));
      u = updates[1];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f5"=>"c","f6"=>"d","command"=>"UPDATE"], u.getChangedFields());
      strictEquals([5=>"c",6=>"d",4=>"UPDATE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"UPDATE","f5"=>"c","f6"=>"d"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"UPDATE",5=>"c",6=>"d"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("UPDATE", u.getValue(4));
      strictEquals("c", u.getValue(5));
      strictEquals("d", u.getValue(6));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("UPDATE", u.getValue("command"));
      strictEquals("c", u.getValue("f5"));
      strictEquals("d", u.getValue("f6"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged(5));
      strictEquals(true, u.isValueChanged(6));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      strictEquals(true, u.isValueChanged("f5"));
      strictEquals(true, u.isValueChanged("f6"));
    })
    .then(() -> {
      ws.onText("U,1,1,A|||UPDATE");
    })
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"A"], u.getChangedFields());
      strictEquals([1=>"A"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"A","f2"=>"b","key"=>"item1","command"=>"UPDATE","f5"=>"c","f6"=>"d"], u.getFields());
      strictEquals([1=>"A",2=>"b",3=>"item1",4=>"UPDATE",5=>"c",6=>"d"], u.getFieldsByPosition());
      strictEquals("A", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("UPDATE", u.getValue(4));
      strictEquals("c", u.getValue(5));
      strictEquals("d", u.getValue(6));
      strictEquals("A", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("UPDATE", u.getValue("command"));
      strictEquals("c", u.getValue("f5"));
      strictEquals("d", u.getValue("f6"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(false, u.isValueChanged(4));
      strictEquals(false, u.isValueChanged(5));
      strictEquals(false, u.isValueChanged(6));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(false, u.isValueChanged("command"));
      strictEquals(false, u.isValueChanged("f5"));
      strictEquals(false, u.isValueChanged("f6"));
    })
    .then(() -> {
      ws.onText("U,2,1,C|");
    })
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[3];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f5"=>"C"], u.getChangedFields());
      strictEquals([5=>"C"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"A","f2"=>"b","key"=>"item1","command"=>"UPDATE","f5"=>"C","f6"=>"d"], u.getFields());
      strictEquals([1=>"A",2=>"b",3=>"item1",4=>"UPDATE",5=>"C",6=>"d"], u.getFieldsByPosition());
      strictEquals("A", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("UPDATE", u.getValue(4));
      strictEquals("C", u.getValue(5));
      strictEquals("d", u.getValue(6));
      strictEquals("A", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("UPDATE", u.getValue("command"));
      strictEquals("C", u.getValue("f5"));
      strictEquals("d", u.getValue("f6"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(false, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged(5));
      strictEquals(false, u.isValueChanged(6));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(false, u.isValueChanged("command"));
      strictEquals(true, u.isValueChanged("f5"));
      strictEquals(false, u.isValueChanged("f6"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testADD_UPD1Level_DEL(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("U,1,1,A|||DELETE");
    })
    .await("control\r\nLS_reqId=3&LS_subId=2&LS_op=delete&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(2, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals(null, u.getValue(5));
      strictEquals(null, u.getValue(6));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(null, u.getValue("f5"));
      strictEquals(null, u.getValue("f6"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(false, u.isValueChanged(5));
      strictEquals(false, u.isValueChanged(6));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      strictEquals(false, u.isValueChanged("f5"));
      strictEquals(false, u.isValueChanged("f6"));
      u = updates[1];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>null,"f2"=>null,"command"=>"DELETE"], u.getChangedFields());
      strictEquals([1=>null,2=>null,4=>"DELETE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"item1","command"=>"DELETE"], u.getFields());
      strictEquals([1=>null,2=>null,3=>"item1",4=>"DELETE"], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals(null, u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("DELETE", u.getValue(4));
      strictEquals(null, u.getValue("f1"));
      strictEquals(null, u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("DELETE", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testADD_UPD2Level_DEL(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals(null, u.getValue(5));
      strictEquals(null, u.getValue(6));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(null, u.getValue("f5"));
      strictEquals(null, u.getValue("f6"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(false, u.isValueChanged(5));
      strictEquals(false, u.isValueChanged(6));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      strictEquals(false, u.isValueChanged("f5"));
      strictEquals(false, u.isValueChanged("f6"));
    })
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("U,2,1,c|d");
    })
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[1];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f5"=>"c","f6"=>"d","command"=>"UPDATE"], u.getChangedFields());
      strictEquals([5=>"c",6=>"d",4=>"UPDATE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"UPDATE","f5"=>"c","f6"=>"d"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"UPDATE",5=>"c",6=>"d"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("UPDATE", u.getValue(4));
      strictEquals("c", u.getValue(5));
      strictEquals("d", u.getValue(6));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("UPDATE", u.getValue("command"));
      strictEquals("c", u.getValue("f5"));
      strictEquals("d", u.getValue("f6"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged(5));
      strictEquals(true, u.isValueChanged(6));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      strictEquals(true, u.isValueChanged("f5"));
      strictEquals(true, u.isValueChanged("f6"));
    })
    .then(() -> ws.onText("U,1,1,|||DELETE"))
    .await("control\r\nLS_reqId=3&LS_subId=2&LS_op=delete&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>null,"f2"=>null,"f5"=>null,"f6"=>null,"command"=>"DELETE"], u.getChangedFields());
      strictEquals([1=>null,2=>null,5=>null,6=>null,4=>"DELETE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"item1","command"=>"DELETE","f5"=>null,"f6"=>null], u.getFields());
      strictEquals([1=>null,2=>null,3=>"item1",4=>"DELETE",5=>null,6=>null], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals(null, u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("DELETE", u.getValue(4));
      strictEquals(null, u.getValue(5));
      strictEquals(null, u.getValue(6));
      strictEquals(null, u.getValue("f1"));
      strictEquals(null, u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("DELETE", u.getValue("command"));
      strictEquals(null, u.getValue("f5"));
      strictEquals(null, u.getValue("f6"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged(5));
      strictEquals(true, u.isValueChanged(6));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      strictEquals(true, u.isValueChanged("f5"));
      strictEquals(true, u.isValueChanged("f6"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testEOS(async: utest.Async) {
    exps
    .then(() -> {
      sub.setRequestedSnapshot("yes");
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> {
      ws.onText("EOS,1,1");
    })
    .await("onEndOfSnapshot i1 1")
    .then(() -> {
      ws.onText("U,1,1,c|d|item2|ADD");
    })
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=3&LS_mode=MERGE&LS_group=item2&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[1];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"item2","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d",3=>"item2",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"item2","command"=>"ADD"], u.getFields());
      strictEquals([1=>"c",2=>"d",3=>"item2",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("item2", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals("item2", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> {
      ws.onText("U,1,2,e|f|item3|ADD");
    })
    .await("control\r\nLS_reqId=4&LS_op=add&LS_subId=4&LS_mode=MERGE&LS_group=item3&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[2];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"e","f2"=>"f","key"=>"item3","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"e",2=>"f",3=>"item3",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"e","f2"=>"f","key"=>"item3","command"=>"ADD"], u.getFields());
      strictEquals([1=>"e",2=>"f",3=>"item3",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("e", u.getValue(1));
      strictEquals("f", u.getValue(2));
      strictEquals("item3", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("e", u.getValue("f1"));
      strictEquals("f", u.getValue("f2"));
      strictEquals("item3", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testCS(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("U,1,2,c|d|item2|ADD");
    })
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=3&LS_mode=MERGE&LS_group=item2&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("SUBOK,3,1,2");
      ws.onText("CS,1,1");
    })
    .await("control\r\nLS_reqId=4&LS_subId=2&LS_op=delete&LS_ack=false")
    .await("onClearSnapshot i1 1")
    .then(() -> {
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      u = updates[1];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"item2","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d",3=>"item2",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"item2","command"=>"ADD"], u.getFields());
      strictEquals([1=>"c",2=>"d",3=>"item2",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("item2", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals("item2", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testUNSUB(async: utest.Async) {
    exps
    .then(() -> {
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f3%20f4&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"item1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"item1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("UNSUB,2");
      ws.onText("U,1,1,|||DELETE");
    })
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[1];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>null,"f2"=>null,"command"=>"DELETE"], u.getChangedFields());
      strictEquals([1=>null,2=>null,4=>"DELETE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"item1","command"=>"DELETE"], u.getFields());
      strictEquals([1=>null,2=>null,3=>"item1",4=>"DELETE"], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals(null, u.getValue(2));
      strictEquals("item1", u.getValue(3));
      strictEquals("DELETE", u.getValue(4));
      strictEquals(null, u.getValue("f1"));
      strictEquals(null, u.getValue("f2"));
      strictEquals("item1", u.getValue("key"));
      strictEquals("DELETE", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testOV1Level(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("OV,1,1,5");
    })
    .await("onItemLostUpdates i1 1 5")
    .then(() -> async.completed())
    .verify();
  }

  function testOV2Level(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("OV,2,1,5");
    })
    .await("onCommandSecondLevelItemLostUpdates 5 item1")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF1Level(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("CONF,1,111,filtered");
    })
    .await("onRealMaxFrequency 111")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF2Level(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,2,111,filtered");
    })
    .await("onRealMaxFrequency 111")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_eq(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,1,111,filtered");
      ws.onText("CONF,2,111,filtered");
    })
    .await("onRealMaxFrequency 111")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_lt(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,1,111,filtered");
      ws.onText("CONF,2,110,filtered");
    })
    .await("onRealMaxFrequency 111")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_gt(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,1,111,filtered");
      ws.onText("CONF,2,112,filtered");
    })
    .await("onRealMaxFrequency 111")
    .await("onRealMaxFrequency 112")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_Changed(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      sub.setRequestedMaxFrequency("456");
    })
    .await("control\r\nLS_reqId=3&LS_subId=2&LS_op=reconf&LS_requested_max_frequency=456")
    .await("control\r\nLS_reqId=4&LS_subId=1&LS_op=reconf&LS_requested_max_frequency=456")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_DEL(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,1,111,filtered");
      ws.onText("CONF,2,unlimited,filtered");
    })
    .await("onRealMaxFrequency 111")
    .await("onRealMaxFrequency unlimited")
    .then(() -> ws.onText("U,1,1,a|b|item1|DELETE"))
    .await("control\r\nLS_reqId=3&LS_subId=2&LS_op=delete&LS_ack=false")
    .await("onItemUpdate")
    .await("onRealMaxFrequency 111")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_DEL_lt(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,1,unlimited,filtered");
      ws.onText("CONF,2,111,filtered");
    })
    .await("onRealMaxFrequency unlimited")
    .then(() -> ws.onText("U,1,1,a|b|item1|DELETE"))
    .await("control\r\nLS_reqId=3&LS_subId=2&LS_op=delete&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_UNSUB(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,1,111,filtered");
      ws.onText("CONF,2,unlimited,filtered");
    })
    .await("onRealMaxFrequency 111")
    .await("onRealMaxFrequency unlimited")
    .then(() -> ws.onText("UNSUB,2"))
    .await("onRealMaxFrequency 111")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_CS(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,1,111,filtered");
      ws.onText("CONF,2,unlimited,filtered");
    })
    .await("onRealMaxFrequency 111")
    .await("onRealMaxFrequency unlimited")
    .then(() -> ws.onText("CS,1,1"))
    .await("control\r\nLS_reqId=3&LS_subId=2&LS_op=delete&LS_ack=false")
    .await("onRealMaxFrequency 111")
    .then(() -> async.completed())
    .verify();
  }

  function testCONF_null(async: utest.Async) {
    exps
    .then(() -> {
      sub.setCommandSecondLevelFields(["f5", "f6"]);
      client.subscribe(sub);
      client.connect();
    })
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_adapter_set=TEST&LS_cid=scFuxkwp1ltvcB4BJ4JikvD9i&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|item1|ADD");
    })
    .await("control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=item1&LS_schema=f5%20f6&LS_snapshot=true&LS_ack=false")
    .await("onItemUpdate")
    .then(() -> {
      ws.onText("SUBOK,2,1,2");
      ws.onText("CONF,2,unlimited,filtered");
    })
    .await("onRealMaxFrequency unlimited")
    .then(() -> ws.onText("U,1,1,a|b|item1|DELETE"))
    .await("control\r\nLS_reqId=3&LS_subId=2&LS_op=delete&LS_ack=false")
    .await("onItemUpdate")
    .await("onRealMaxFrequency null")
    .then(() -> async.completed())
    .verify();
  }
}