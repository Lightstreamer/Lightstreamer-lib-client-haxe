package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener;

@:timeout(500)
class TestDiffPatch extends utest.Test {
  var ws: MockWsClient;
  var client: LightstreamerClient;
  var subListener: BaseSubscriptionListener;
  var sub: Subscription;

  function setup() {
    ws = new MockWsClient(this);
    client = new LightstreamerClient("http://server", "TEST", ws.create);
    subListener = new BaseSubscriptionListener();
    sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setRequestedSnapshot("yes");
    sub.addListener(subListener);
  }

  function teardown() {
    client.disconnect();
  }

  function updateTemplate(async: utest.Async, updates: Array<String>, outputs: Array<String>) {
    exps
    .then(() -> {
      subListener._onItemUpdate = update -> {
        exps.signal(update.getValue(1));
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=count&LS_schema=count&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,1");
      for (upd in updates) {
        ws.onText("U,1,1," + upd);
      }
    });

    for (out in outputs) {
      exps.await(out);
    }

    exps
    .then(() -> async.completed())
    .verify();
  }

  function errorTemplate(async: utest.Async, updates: Array<String>, expectedError: String) {
    exps
    .then(() -> {
      var listener = new BaseClientListener();
      listener._onServerError = (code, msg) -> exps.signal('$code - $msg');
      client.addListener(listener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=count&LS_schema=count&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,1");
      for (upd in updates) {
        ws.onText("U,1,1," + upd);
      }
    })
    .await("control\r\nLS_reqId=2&LS_op=destroy&LS_close_socket=true&LS_cause=api")
    .await("ws.dispose")
    .await(expectedError)
    .then(() -> async.completed())
    .verify();
  }

  @:timeout(3000)
  function testRealServer(async: utest.Async) {
    var updates = [];
    #if android
    var host = "http://10.0.2.2:8080";
    #else
    var host = "http://localtest.me:8080";
    #end
    client = new LightstreamerClient(host, "TEST");
    sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setRequestedSnapshot("no");
    sub.setDataAdapter("DIFF_COUNT");
    sub.addListener(subListener);
    subListener._onItemUpdate = update -> {
      updates.push(update);
      exps.signal("onItemUpdate");
    }
    client.subscribe(sub);

    exps
    .then(() -> client.connect())
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[1];
      match(~/value=\d+/, u.getValue(1));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testMultiplePatches(async: utest.Async) {
    updateTemplate(async, [
      "foobar", 
      "^Tbdzapcd", // copy(1)add(3,zap)del(2)copy(3)
      "^Taabg", // copy(0)add(0)del(1)copy(6)
      "^Tddxyz", // copy(3)add(3,xyz)
    ], [
      "foobar", 
      "fzapbar",
      "zapbar",
      "zapxyz",
    ]);
  }

  function testPercentEncoding(async: utest.Async) {
    updateTemplate(async, [
      "foo", 
      "^Tdg%25%24%3D%2C%2B%7C", // copy(3)add(6,%$=,+|)
    ], [
      "foo",
      "foo%$=,+|", 
    ]);
  }

  function testApplyToEmptyString(async: utest.Async) {
    updateTemplate(async, [
      "$", 
      "^Tadfoo", // copy(0)add(3,foo)
    ], [
      "", 
      "foo",
    ]);
  }

  function testApplyToString(async: utest.Async) {
    updateTemplate(async, [
      "foobar", 
      "^Tbaeb", // copy(1)add(0)del(4)copy(1)
    ], [
      "foobar", 
      "fr",
    ]);
  }

  function testApplyToNull(async: utest.Async) {
    errorTemplate(async, [
      "#", 
      "^Tbaeb", // copy(1)add(0)del(4)copy(1)
    ], "61 - Cannot apply the TLCP-diff to the field 1 because the field is null");
  }

  function testApplyToJson(async: utest.Async) {
    errorTemplate(async, [
      '{}', 
      '^P[{"op":"add","path":"/foo","value":1}]',
      "^Tbaeb", // copy(1)add(0)del(4)copy(1)
    ], "61 - Cannot apply the TLCP-diff to the field 1 because the field is JSON");
  }

  function testFirstUpdateIsDiffPatch(async: utest.Async) {
    errorTemplate(async, [
      "^Tbaeb", // copy(1)add(0)del(4)copy(1)
    ], "61 - Cannot set the field 1 because the first update is a TLCP-diff");
  }

  function testBadDiff_OutOfRange(async: utest.Async) {
    errorTemplate(async, [
      "foo", 
      "^Tz", // copy(25)
    ], "61 - Bad TLCP-diff");
  }

  function testBadDiff_InvalidChar(async: utest.Async) {
    errorTemplate(async, [
      "foo", 
      "^T!",
    ], "61 - Bad TLCP-diff");
  }

  function testIsChanged(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onItemUpdate = update -> {
        exps.signal("value " + update.getValue(1));
        exps.signal("changed " + update.isValueChanged(1));
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=count&LS_schema=count&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,1");
      ws.onText("U,1,1," + "foo");
      ws.onText("U,1,1,");
      ws.onText("U,1,1," + '^Tc');
      ws.onText("U,1,1," + "#");
    })
    .await("value foo")
    .await("changed true")
    .await("value foo")
    .await("changed false")
    .await('value fo')
    .await("changed true")
    .await("value null")
    .await("changed true")
    .then(() -> async.completed())
    .verify();
  }

  function testGetFields(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onItemUpdate = update -> {
        var value = update.getValue(1);
        var changed = update.isValueChanged(1);
        exps.signal("isChanged " + changed + " value " + value );
        for (name => val in (update.getFields():Map<String,String>)) {
          exps.signal("fields: " + name + " " + val);
        }
        for (name => val in (update.getChangedFields():Map<String,String>)) {
          exps.signal("changed fields: " + name + " " + val);
        }
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=count&LS_schema=count&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,1");
      ws.onText("U,1,1," + "foo");
      ws.onText("U,1,1,");
      ws.onText("U,1,1," + '^Tc');
      ws.onText("U,1,1," + "#");
    })
    .await("isChanged true value foo")
    .await('fields: count foo')
    .await('changed fields: count foo')
    .await('isChanged false value foo')
    .await('fields: count foo')
    .await('isChanged true value fo')
    .await('fields: count fo')
    .await('changed fields: count fo')
    .await('isChanged true value null')
    .await('fields: count null')
    .await('changed fields: count null')
    .then(() -> async.completed())
    .verify();
  }

  function testCOMMAND_Case1(async: utest.Async) {
    var updates = [];
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1"], ["key", "command", "value"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
      subListener._onItemUpdate = update -> {
        updates.push(update);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1&LS_schema=key%20command%20value&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,1,3,1,2");
      ws.onText('U,1,1,k1|ADD|foo');
      ws.onText('U,1,1,k2|ADD|^Tc');
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      equals("k1", u.getValue("key"));
      equals('foo', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[1];
      equals("k2", u.getValue("key"));
      equals('fo', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testCOMMAND_Case2(async: utest.Async) {
    var updates = [];
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1"], ["key", "command", "value"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
      subListener._onItemUpdate = update -> {
        updates.push(update);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1&LS_schema=key%20command%20value&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,1,3,1,2");
      ws.onText('U,1,1,k2|ADD|foo');
      ws.onText('U,1,1,k1|ADD|^Tc');
      ws.onText('U,1,1,k2|UPDATE|^Tb');
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      equals("k2", u.getValue("key"));
      equals('foo', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[1];
      equals("k1", u.getValue("key"));
      equals('fo', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[2];
      equals("k2", u.getValue("key"));
      equals('f', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testCOMMAND2Level(async: utest.Async) {
    var updates = [];
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1"], ["key", "command"]);
      sub.setRequestedSnapshot("no");
      sub.setCommandSecondLevelFields(["value"]);
      sub.addListener(subListener);
      subListener._onItemUpdate = update -> {
        updates.push(update);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1&LS_schema=key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,1,2,1,2");
      ws.onText("U,1,1,k1|ADD");
    })
    .await("onItemUpdate", "control\r\nLS_reqId=2&LS_op=add&LS_subId=2&LS_mode=MERGE&LS_group=k1&LS_schema=value&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,2,1,1");
      ws.onText('U,2,1,foo');
      ws.onText('U,2,1,^Tc');
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      equals("k1", u.getValue("key"));
      equals(null, u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[1];
      equals("k1", u.getValue("key"));
      equals('foo', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[2];
      equals("k1", u.getValue("key"));
      equals('fo', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
    })
    .then(() -> ws.onText("U,1,1,k1|DELETE"))
    .await("onItemUpdate", "control\r\nLS_reqId=3&LS_subId=2&LS_op=delete&LS_ack=false")
    .then(() -> {
      var u = updates[3];
      equals("k1", u.getValue("key"));
      equals("DELETE", u.getValue("command"));
      equals(null, u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
    })
    .then(() -> async.completed())
    .verify();
  }
}