package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener;

class TestJsonPatch extends utest.Test {
  var ws: MockWsClient;
  var client: LightstreamerClient;
  var subListener: BaseSubscriptionListener;
  var sub: Subscription;

  function setup() {
    ws = new MockWsClient(this);
    client = new LightstreamerClient("http://server", "TEST", new TestFactory(this, ws));
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
        exps.signal("value " + update.getValue(1));
        exps.signal("patch " + patch2str(update.getValueAsJSONPatchIfAvailable(1)));
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
    sub.setDataAdapter("JSON_COUNT");
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
      var patch = patch2json(u.getValueAsJSONPatchIfAvailable(1))[0];
      equals("replace", patch.op);
      equals("/value", patch.path);
      notNull(patch.value);
      var value = haxe.Json.parse(u.getValue(1));
      notNull(value.value);
    })
    .then(() -> async.completed())
    .verify();
  }

  @:timeout(3000)
  function testRealServer_JsonAndTxt(async: utest.Async) {
    var updates = [];
    #if android
    var host = "http://10.0.2.2:8080";
    #else
    var host = "http://localtest.me:8080";
    #end
    client = new LightstreamerClient(host, "TEST");
    sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setRequestedMaxFrequency("unfiltered");
    sub.setRequestedSnapshot("no");
    sub.setDataAdapter("JSON_DIFF_COUNT");
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
    .await("onItemUpdate")
    .then(() -> {
      isNull(updates[0].getValueAsJSONPatchIfAvailable(1));
      notNull(updates[1].getValueAsJSONPatchIfAvailable(1));
      isNull(updates[2].getValueAsJSONPatchIfAvailable(1));
    })
    .then(() -> client.unsubscribe(sub))
    .then(() -> async.completed())
    .verify();
  }

  @:timeout(3000)
  function testRealServer_LongJsonAndShortJson(async: utest.Async) {
    var updates = [];
    #if android
    var host = "http://10.0.2.2:8080";
    #else
    var host = "http://localtest.me:8080";
    #end
    client = new LightstreamerClient(host, "TEST");
    sub = new Subscription("MERGE", ["count"], ["count"]);
    sub.setRequestedMaxFrequency("unfiltered");
    sub.setRequestedSnapshot("no");
    sub.setDataAdapter("DIFF_JSON_COUNT");
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
    .await("onItemUpdate")
    .then(() -> {
      isNull(updates[0].getValueAsJSONPatchIfAvailable(1));
      isNull(updates[1].getValueAsJSONPatchIfAvailable(1));
      isNull(updates[2].getValueAsJSONPatchIfAvailable(1));
    })
    .then(() -> client.unsubscribe(sub))
    .then(() -> async.completed())
    .verify();
  }

  function testMultiLevelPatches(async: utest.Async) {
    updateTemplate(async, [
      '{"seqNo":328352,"exchangeTimeNs":0,"bidLevels":[{"price":95.375,"qty":105,"impliedQty":0,"noOfOrders":2,"orderCount":0,"orderQty":[]},{"price":95.37,"qty":17001,"impliedQty":8375,"noOfOrders":45,"orderCount":0,"orderQty":[]},{"price":95.365,"qty":27310,"impliedQty":25326,"noOfOrders":56,"orderCount":0,"orderQty":[]},{"price":95.36,"qty":1351,"impliedQty":0,"noOfOrders":37,"orderCount":0,"orderQty":[]},{"price":95.355,"qty":1044,"impliedQty":0,"noOfOrders":34,"orderCount":0,"orderQty":[]}],"askLevels":[{"price":95.38,"qty":31164,"impliedQty":19843,"noOfOrders":70,"orderCount":0,"orderQty":[]},{"price":95.385,"qty":12260,"impliedQty":10568,"noOfOrders":33,"orderCount":0,"orderQty":[]},{"price":95.39,"qty":1274,"impliedQty":0,"noOfOrders":29,"orderCount":0,"orderQty":[]},{"price":95.395,"qty":1006,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]},{"price":95.4,"qty":1387,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]}]}',

      '{"seqNo":328354,"exchangeTimeNs":0,"bidLevels":[{"price":95.37,"qty":21709,"impliedQty":7907,"noOfOrders":49,"orderCount":0,"orderQty":[]},{"price":95.365,"qty":23514,"impliedQty":21494,"noOfOrders":53,"orderCount":0,"orderQty":[]},{"price":95.36,"qty":1338,"impliedQty":0,"noOfOrders":34,"orderCount":0,"orderQty":[]},{"price":95.355,"qty":1031,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]},{"price":95.35000000000001,"qty":896,"impliedQty":0,"noOfOrders":35,"orderCount":0,"orderQty":[]}],"askLevels":[{"price":95.375,"qty":100,"impliedQty":0,"noOfOrders":3,"orderCount":0,"orderQty":[]},{"price":95.38,"qty":23857,"impliedQty":20194,"noOfOrders":59,"orderCount":0,"orderQty":[]},{"price":95.385,"qty":10989,"impliedQty":9221,"noOfOrders":33,"orderCount":0,"orderQty":[]},{"price":95.39,"qty":1267,"impliedQty":0,"noOfOrders":28,    "orderCount":0,"orderQty":[]},{"price":95.395,"qty":993,"impliedQty":0,"noOfOrders":30,"orderCount":0,"orderQty":[]}]}', 

      '^P[{"op":"replace","path":"/seqNo","value":328355},{"op":"replace","path":"/askLevels/1/qty","value":24450},{"op":"replace","path":"/askLevels/1/impliedQty","value":20787}]', 

      '^P[{"op":"replace","path":"/seqNo","value":328356},{"op":"replace","path":"/askLevels/1/qty","value":25054},{"op":"replace","path":"/askLevels/1/impliedQty","value":21391}]'
    ],
    [
      'value {"seqNo":328352,"exchangeTimeNs":0,"bidLevels":[{"price":95.375,"qty":105,"impliedQty":0,"noOfOrders":2,"orderCount":0,"orderQty":[]},{"price":95.37,"qty":17001,"impliedQty":8375,"noOfOrders":45,"orderCount":0,"orderQty":[]},{"price":95.365,"qty":27310,"impliedQty":25326,"noOfOrders":56,"orderCount":0,"orderQty":[]},{"price":95.36,"qty":1351,"impliedQty":0,"noOfOrders":37,"orderCount":0,"orderQty":[]},{"price":95.355,"qty":1044,"impliedQty":0,"noOfOrders":34,"orderCount":0,"orderQty":[]}],"askLevels":[{"price":95.38,"qty":31164,"impliedQty":19843,"noOfOrders":70,"orderCount":0,"orderQty":[]},{"price":95.385,"qty":12260,"impliedQty":10568,"noOfOrders":33,"orderCount":0,"orderQty":[]},{"price":95.39,"qty":1274,"impliedQty":0,"noOfOrders":29,"orderCount":0,"orderQty":[]},{"price":95.395,"qty":1006,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]},{"price":95.4,"qty":1387,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]}]}', 
      'patch null',

      'value {"seqNo":328354,"exchangeTimeNs":0,"bidLevels":[{"price":95.37,"qty":21709,"impliedQty":7907,"noOfOrders":49,"orderCount":0,"orderQty":[]},{"price":95.365,"qty":23514,"impliedQty":21494,"noOfOrders":53,"orderCount":0,"orderQty":[]},{"price":95.36,"qty":1338,"impliedQty":0,"noOfOrders":34,"orderCount":0,"orderQty":[]},{"price":95.355,"qty":1031,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]},{"price":95.35000000000001,"qty":896,"impliedQty":0,"noOfOrders":35,"orderCount":0,"orderQty":[]}],"askLevels":[{"price":95.375,"qty":100,"impliedQty":0,"noOfOrders":3,"orderCount":0,"orderQty":[]},{"price":95.38,"qty":23857,"impliedQty":20194,"noOfOrders":59,"orderCount":0,"orderQty":[]},{"price":95.385,"qty":10989,"impliedQty":9221,"noOfOrders":33,"orderCount":0,"orderQty":[]},{"price":95.39,"qty":1267,"impliedQty":0,"noOfOrders":28,    "orderCount":0,"orderQty":[]},{"price":95.395,"qty":993,"impliedQty":0,"noOfOrders":30,"orderCount":0,"orderQty":[]}]}', 
      'patch null',

      'value {"seqNo":328355,"exchangeTimeNs":0,"bidLevels":[{"price":95.37,"qty":21709,"impliedQty":7907,"noOfOrders":49,"orderCount":0,"orderQty":[]},{"price":95.365,"qty":23514,"impliedQty":21494,"noOfOrders":53,"orderCount":0,"orderQty":[]},{"price":95.36,"qty":1338,"impliedQty":0,"noOfOrders":34,"orderCount":0,"orderQty":[]},{"price":95.355,"qty":1031,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]},{"price":95.35000000000001,"qty":896,"impliedQty":0,"noOfOrders":35,"orderCount":0,"orderQty":[]}],"askLevels":[{"price":95.375,"qty":100,"impliedQty":0,"noOfOrders":3,"orderCount":0,"orderQty":[]},{"price":95.38,"qty":24450,"impliedQty":20787,"noOfOrders":59,"orderCount":0,"orderQty":[]},{"price":95.385,"qty":10989,"impliedQty":9221,"noOfOrders":33,"orderCount":0,"orderQty":[]},{"price":95.39,"qty":1267,"impliedQty":0,"noOfOrders":28,"orderCount":0,"orderQty":[]},{"price":95.395,"qty":993,"impliedQty":0,"noOfOrders":30,"orderCount":0,"orderQty":[]}]}', 
      'patch [{"op":"replace","path":"/seqNo","value":328355},{"op":"replace","path":"/askLevels/1/qty","value":24450},{"op":"replace","path":"/askLevels/1/impliedQty","value":20787}]',

      'value {"seqNo":328356,"exchangeTimeNs":0,"bidLevels":[{"price":95.37,"qty":21709,"impliedQty":7907,"noOfOrders":49,"orderCount":0,"orderQty":[]},{"price":95.365,"qty":23514,"impliedQty":21494,"noOfOrders":53,"orderCount":0,"orderQty":[]},{"price":95.36,"qty":1338,"impliedQty":0,"noOfOrders":34,"orderCount":0,"orderQty":[]},{"price":95.355,"qty":1031,"impliedQty":0,"noOfOrders":32,"orderCount":0,"orderQty":[]},{"price":95.35000000000001,"qty":896,"impliedQty":0,"noOfOrders":35,"orderCount":0,"orderQty":[]}],"askLevels":[{"price":95.375,"qty":100,"impliedQty":0,"noOfOrders":3,"orderCount":0,"orderQty":[]},{"price":95.38,"qty":25054,"impliedQty":21391,"noOfOrders":59,"orderCount":0,"orderQty":[]},{"price":95.385,"qty":10989,"impliedQty":9221,"noOfOrders":33,"orderCount":0,"orderQty":[]},{"price":95.39,"qty":1267,"impliedQty":0,"noOfOrders":28,"orderCount":0,"orderQty":[]},{"price":95.395,"qty":993,"impliedQty":0,"noOfOrders":30,"orderCount":0,"orderQty":[]}]}', 
      'patch [{"op":"replace","path":"/seqNo","value":328356},{"op":"replace","path":"/askLevels/1/qty","value":25054},{"op":"replace","path":"/askLevels/1/impliedQty","value":21391}]',
    ]);
  }

  function testPatches(async: utest.Async) {
    updateTemplate(async, ['{"baz":"qux","foo":"bar"}', 
    '^P[{ "op": "replace", "path": "/baz", "value": "boo" }]', 
    '^P[{ "op": "add", "path": "/hello", "value": ["world"] }]', 
    '^P[{ "op": "remove", "path": "/foo" }]'],
    ['value {"baz":"qux","foo":"bar"}', 'patch null',
    'value {"baz":"boo","foo":"bar"}', 
    #if cs 'patch [{"value":"boo","path":"/baz","op":"replace"}]' 
    #else  'patch [{"op":"replace","path":"/baz","value":"boo"}]' #end,
    'value {"baz":"boo","foo":"bar","hello":["world"]}', 
    #if cs 'patch [{"value":["world"],"path":"/hello","op":"add"}]' 
    #else  'patch [{"op":"add","path":"/hello","value":["world"]}]' #end ,
    'value {"baz":"boo","hello":["world"]}', 
    #if cs 'patch [{"path":"/foo","op":"remove"}]' 
    #else  'patch [{"op":"remove","path":"/foo"}]' #end]);
  }

  function testMultiplePatches(async: utest.Async) {
    updateTemplate(async, ['{"baz":"qux","foo":"bar"}', 
    '^P[{ "op": "replace", "path": "/baz", "value": "boo" },{ "op": "add", "path": "/hello", "value": ["world"] },{ "op": "remove", "path": "/foo" }]'],
    ['value {"baz":"qux","foo":"bar"}', 'patch null',
    'value {"baz":"boo","hello":["world"]}', 
    #if cs 'patch [{"value":"boo","path":"/baz","op":"replace"},{"value":["world"],"path":"/hello","op":"add"},{"path":"/foo","op":"remove"}]'
    #else  'patch [{"op":"replace","path":"/baz","value":"boo"},{"op":"add","path":"/hello","value":["world"]},{"op":"remove","path":"/foo"}]' #end]);
  }

  function testInvalidPatch(async: utest.Async) {
    errorTemplate(async, ['{}', '^Pfoo'],
    "61 - The JSON Patch for the field 1 is not well-formed");
  }
  function testInvalidJson(async: utest.Async) {
    errorTemplate(async, ['foo', '^P[]'],
    "61 - Cannot convert the field 1 to JSON");
  }
  function testInvalidApply(async: utest.Async) {
    errorTemplate(async, ['{}', '^P[{ "op": "replace", "path": "/baz", "value": "boo" }]'],
    "61 - Cannot apply the JSON Patch to the field 1");
  }
  function testInvalidApply_Null(async: utest.Async) {
    errorTemplate(async, ['#', '^P[]'],
    "61 - Cannot apply the JSON patch to the field 1 because the field is null");
  }

  function testEmptyString(async: utest.Async) {
    updateTemplate(async, ["$"],
    ['value ', 'patch null']);
  }

  function testFromInitEvtNull(async: utest.Async) {
    updateTemplate(async, ["#"], 
    ["value null", "patch null"]);
  }
  function testFromInitEvtString(async: utest.Async) {
    updateTemplate(async, ["foo"],
    ["value foo", "patch null"]);
  }
  function testFromInitEvtPatch(async: utest.Async) {
    errorTemplate(async, ['^P[{"op":"add","path":"/foo","value":1}]'],
    "61 - Cannot set the field 1 because the first update is a JSONPatch");
  }
  function testFromInitEvtUnchanged(async: utest.Async) {
    errorTemplate(async, [""],
    "61 - Cannot set the field 1 because the first update is UNCHANGED");
  }

  function testFromStringEvtNull(async: utest.Async) {
    updateTemplate(async, ["foo", "#"], 
    ["value foo", "patch null",
    "value null", "patch null"]);
  }
  function testFromStringEvtString(async: utest.Async) {
    updateTemplate(async, ["foo", "bar"],
    ["value foo", "patch null",
    "value bar", "patch null"]);
  }
  function testFromStringEvtPatch(async: utest.Async) {
    updateTemplate(async, ['{}', '^P[{"op":"add","path":"/foo","value":1}]'],
    ['value {}', 'patch null',
    'value {"foo":1}', 
    #if cs 'patch [{"value":1,"path":"/foo","op":"add"}]'
    #else  'patch [{"op":"add","path":"/foo","value":1}]' #end]);
  }
  function testFromStringEvtUnchanged(async: utest.Async) {
    updateTemplate(async, ["foo", ""],
    ["value foo", "patch null",
    "value foo", "patch null"]);
  }

  function testFromJsonEvtNull(async: utest.Async) {
    updateTemplate(async, ['{}', '^P[{"op":"add","path":"/foo","value":1}]', '#'],
    ['value {}', 'patch null',
    'value {"foo":1}', 
    #if cs 'patch [{"value":1,"path":"/foo","op":"add"}]'
    #else  'patch [{"op":"add","path":"/foo","value":1}]' #end,
    'value null', 'patch null']);
  }
  function testFromJsonEvtString(async: utest.Async) {
    updateTemplate(async, ['{}', '^P[{"op":"add","path":"/foo","value":1}]', 'foo'],
    ['value {}', 'patch null',
    'value {"foo":1}', 
    #if cs 'patch [{"value":1,"path":"/foo","op":"add"}]'
    #else  'patch [{"op":"add","path":"/foo","value":1}]' #end,
    'value foo', 'patch null']);
  }
  function testFromJsonEvtPatch(async: utest.Async) {
    updateTemplate(async, ['{}', '^P[{"op":"add","path":"/foo","value":1}]', '^P[{"op":"add","path":"/bar","value":2}]'],
    ['value {}', 'patch null',
    'value {"foo":1}', 
    #if cs 'patch [{"value":1,"path":"/foo","op":"add"}]'
    #else  'patch [{"op":"add","path":"/foo","value":1}]' #end,
    'value {"foo":1,"bar":2}', 
    #if cs 'patch [{"value":2,"path":"/bar","op":"add"}]'
    #else  'patch [{"op":"add","path":"/bar","value":2}]' #end]);
  }
  function testFromJsonEvtUnchanged(async: utest.Async) {
    updateTemplate(async, ['{}', '^P[{"op":"add","path":"/foo","value":1}]', ''],
    ['value {}', 'patch null',
    'value {"foo":1}', 
    #if cs 'patch [{"value":1,"path":"/foo","op":"add"}]'
    #else  'patch [{"op":"add","path":"/foo","value":1}]' #end,
    'value {"foo":1}', 'patch []']);
  }

  function testFromNullEvtNull(async: utest.Async) {
    updateTemplate(async, ["#", "#"], 
    ["value null", "patch null",
    "value null", "patch null"]);
  }
  function testFromNullEvtString(async: utest.Async) {
    updateTemplate(async, ["#", "foo"], 
    ["value null", "patch null",
    "value foo", "patch null"]);
  }
  function testFromNullEvtPatch(async: utest.Async) {
    errorTemplate(async, ["#", '^P[{"op":"add","path":"/foo","value":1}]'], 
    "61 - Cannot apply the JSON patch to the field 1 because the field is null");
  }
  function testFromNullEvtUnchanged(async: utest.Async) {
    updateTemplate(async, ["#", ""], 
    ["value null", "patch null",
    "value null", "patch null"]);
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
      ws.onText("U,1,1," + "{}");
      ws.onText("U,1,1,");
      ws.onText("U,1,1," + '^P[{"op":"add","path":"/foo","value":1}]');
      ws.onText("U,1,1," + "#");
    })
    .await("value {}")
    .await("changed true")
    .await("value {}")
    .await("changed false")
    .await('value {"foo":1}')
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
      ws.onText("U,1,1," + "{}");
      ws.onText("U,1,1,");
      ws.onText("U,1,1," + '^P[{"op":"add","path":"/foo","value":1}]');
      ws.onText("U,1,1," + "#");
    })
    .await("isChanged true value {}")
    .await('fields: count {}')
    .await('changed fields: count {}')
    .await('isChanged false value {}')
    .await('fields: count {}')
    .await('isChanged true value {"foo":1}')
    .await('fields: count {"foo":1}')
    .await('changed fields: count {"foo":1}')
    .await('isChanged true value null')
    .await('fields: count null')
    .await('changed fields: count null')
    .then(() -> async.completed())
    .verify();
  }

  function testIsSnapshot(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onItemUpdate = update -> {
        exps.signal("value " + update.getValue(1));
        exps.signal("snapshot " + update.isSnapshot());
      };
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=count&LS_schema=count&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,1,1");
      ws.onText("U,1,1,foo");
      ws.onText("U,1,1,bar");
    })
    .await("value foo")
    .await("snapshot true")
    .await("value bar")
    .await("snapshot false")
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
      ws.onText('U,1,1,k1|ADD|{"x":1}');
      ws.onText('U,1,1,k2|ADD|^P[{ "op": "replace", "path": "/x", "value": 2 }]');
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      equals("k1", u.getValue("key"));
      equals('{"x":1}', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[1];
      equals("k2", u.getValue("key"));
      equals('{"x":2}', u.getValue("value"));
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
      ws.onText('U,1,1,k2|ADD|{"x":1}');
      ws.onText('U,1,1,k1|ADD|^P[{ "op": "replace", "path": "/x", "value": 2 }]');
      ws.onText('U,1,1,k2|UPDATE|^P[{ "op": "replace", "path": "/x", "value": 3 }]');
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      var u = updates[0];
      equals("k2", u.getValue("key"));
      equals('{"x":1}', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[1];
      equals("k1", u.getValue("key"));
      equals('{"x":2}', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[2];
      equals("k2", u.getValue("key"));
      equals('{"x":3}', u.getValue("value"));
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
      ws.onText('U,2,1,{"x":1}');
      ws.onText('U,2,1,^P[{ "op": "replace", "path": "/x", "value": 2 }]');
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
      equals('{"x":1}', u.getValue("value"));
      equals(null, u.getValueAsJSONPatchIfAvailable("value"));
      u = updates[2];
      equals("k1", u.getValue("key"));
      equals('{"x":2}', u.getValue("value"));
      equals(#if cs '[{"value":2,"path":"/x","op":"replace"}]' #else '[{"op":"replace","path":"/x","value":2}]' #end, patch2str(u.getValueAsJSONPatchIfAvailable("value")));
      equals(#if cs '[{"value":2,"path":"/x","op":"replace"}]' #else '[{"op":"replace","path":"/x","value":2}]' #end, patch2str(u.getValueAsJSONPatchIfAvailable(3)));
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