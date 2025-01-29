package com.lightstreamer.client.internal;

import com.lightstreamer.client.BaseListener.BaseSubscriptionListener;
import com.lightstreamer.client.internal.ParseTools;
import com.lightstreamer.internal.Types.FieldValue;

class TestUpdate extends utest.Test {
  var client: LightstreamerClient;
  var subListener: BaseSubscriptionListener;
  var ws: MockWsClient;
  var sub: Subscription;
  var updates: Array<ItemUpdate>;

  function setup() {
    ws = new MockWsClient(this);
    client = new LightstreamerClient("http://server", "TEST", new TestFactory(this, ws));
    subListener = new BaseSubscriptionListener();
    subListener._onItemUpdate = update -> {
      updates.push(update);
      exps.signal("onItemUpdate");
    };
    subListener._onEndOfSnapshot = (name, pos) -> exps.signal('onEndOfSnapshot $name $pos');
    updates = [];
  }

  function teardown() {
    client.disconnect();
  }

  // Tests that the `unquote` function correctly encodes and decodes UTF-8 byte sequences.
  function testUtf8Decoding() {
    var s = "\u{0}\u{f2}\u{2}\u{0}";
    // Get the utf-8 encoding of `s`
    var bytes = haxe.io.Bytes.ofString(s, haxe.io.Encoding.UTF8);
    // The UTF-8 encoding of `s` is the array [0x00, 0xc3, 0xb2, 0x02, 0x00]
    equals("00c3b20200", bytes.toHex());
    #if js
    // NOTE: in the JavaScript target, the Bytes class (once used internally by `unquote`) fails to convert a UTF-8 array back to a string.
    // For example, in this case, it should return `s`, but it returns an empty string instead.
    notEquals(s, bytes.toString()); // THIS IS WRONG!
    // The TextDecoder class works correctly, so now `unquote` is based on it.
    equals(s, new js.html.TextDecoder().decode(bytes.getData()));
    #end
    // The unquote of `s` is the same as `s`
    equals(s, unquote(s));

    equals("\u{20}\u{00DD}\u{20}\u{20}", unquote("\u{20}\u{00DD}\u{20}\u{20}"));

    // Other tests suggested in https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt
    equals("κόσμε", unquote("κόσμε"));
    equals("\u{00000000}", unquote("\u{00000000}"));
    equals("\u{00000080}", unquote("\u{00000080}"));
    equals("\u{00000800}", unquote("\u{00000800}"));
    equals("\u{00010000}", unquote("\u{00010000}"));

    equals("\u{0000007F}", unquote("\u{0000007F}"));
    equals("\u{000007FF}", unquote("\u{000007FF}"));
    equals("\u{0000FFFF}", unquote("\u{0000FFFF}"));

    equals("\u{0000D7FF}", unquote("\u{0000D7FF}"));
    equals("\u{0000E000}", unquote("\u{0000E000}"));
    equals("\u{0000FFFD}", unquote("\u{0000FFFD}"));
    equals("\u{0010FFFF}", unquote("\u{0010FFFF}"));
  }

  function testUnquote() {
    equals("", unquote(""));
    equals("☺", unquote("☺")); // unicode code point U+263A
    equals("☺", unquote("%E2%98%BA"));
    equals("baràè", unquote("baràè"));
    equals("baràè%", unquote("bar%c3%a0%C3%A8%25"));
    equals("http://via.placeholder.com/256/cbf1a2/61c73f?text=nick+242+Iñtërnâtiônàlizætiøn☃", unquote("http://via.placeholder.com/256/cbf1a2/61c73f?text=nick+242+I%C3%B1t%C3%ABrn%C3%A2ti%C3%B4n%C3%A0liz%C3%A6ti%C3%B8n%E2%98%83"));
  }

  function testDecodingAlgorithm() {
    equals(3, parseUpdate("U,3,1,abc").subId);
    equals(1, parseUpdate("U,3,1,abc").itemIdx);

    equals([1 => changed("abc")], parseUpdate("U,3,1,abc").values);
    equals([1 => changed("😀")], parseUpdate("U,3,1,😀").values);
    equals([1 => changed("baràè%#$^")], parseUpdate("U,3,1,bar%c3%a0%C3%A8%25%23%24%5E").values);

    equals([
      1 => changed("20:00:33"),
      2 => changed("3.04"),
      3 => changed("0.0"),
      4 => changed("2.41"),
      5 => changed("3.67"),
      6 => changed("3.03"),
      7 => changed("3.04"),
      8 => changed(null),
      9 => changed(null),
      10 => changed(""),
    ], parseUpdate("U,3,1,20:00:33|3.04|0.0|2.41|3.67|3.03|3.04|#|#|$").values);
    
    equals([
        1 => changed("20:00:54"),
        2 => changed("3.07"),
        3 => changed("0.98"),
        4 => unchanged,
        5 => unchanged,
        6 => changed("3.06"),
        7 => changed("3.07"),
        8 => unchanged,
        9 => unchanged,
        10 => changed("Suspended"),
    ], parseUpdate("U,3,1,20:00:54|3.07|0.98|||3.06|3.07|||Suspended").values);
    
    equals([
        1 => changed("20:04:16"),
        2 => changed("3.02"),
        3 => changed("-0.65"),
        4 => unchanged,
        5 => unchanged,
        6 => changed("3.01"),
        7 => changed("3.02"),
        8 => unchanged,
        9 => unchanged,
        10 => changed(""),
    ], parseUpdate("U,3,1,20:04:16|3.02|-0.65|||3.01|3.02|||$").values);
    
    equals([
        1 => changed("20:06:10"),
        2 => changed("3.05"),
        3 => changed("0.32"),
        4 => unchanged,
        5 => unchanged,
        6 => unchanged,
        7 => unchanged,
        8 => unchanged,
        9 => unchanged,
        10 => unchanged,
    ], parseUpdate("U,3,1,20:06:10|3.05|0.32|^7").values);
    
    equals([
        1 => changed("20:06:49"),
        2 => changed("3.08"),
        3 => changed("1.31"),
        4 => unchanged,
        5 => unchanged,
        6 => changed("3.08"),
        7 => changed("3.09"),
        8 => unchanged,
        9 => unchanged,
        10 => unchanged,
    ], parseUpdate("U,3,1,20:06:49|3.08|1.31|||3.08|3.09|||").values);
  }

  function testNull(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("RAW", ["i1", "i2"], ["f1", "f2", "f3", "f4"]);
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=RAW&LS_group=i1%20i2&LS_schema=f1%20f2%20f3%20f4&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,4");
      ws.onText("U,1,1,#|#|$|z");
      ws.onText("U,1,1,|n|#|#");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(2, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>null,"f2"=>null,"f3"=>"","f4"=>"z"], u.getChangedFields());
      strictEquals([1=>null,2=>null,3=>"",4=>"z"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>null,"f3"=>"","f4"=>"z"], u.getFields());
      strictEquals([1=>null,2=>null,3=>"",4=>"z"], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals(null, u.getValue(2));
      strictEquals("", u.getValue(3));
      strictEquals("z", u.getValue(4));
      strictEquals(null, u.getValue("f1"));
      strictEquals(null, u.getValue("f2"));
      strictEquals("", u.getValue("f3"));
      strictEquals("z", u.getValue("f4"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("f3"));
      strictEquals(true, u.isValueChanged("f4"));
      u = updates[1];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"n","f3"=>null,"f4"=>null], u.getChangedFields());
      strictEquals([2=>"n",3=>null,4=>null], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>"n","f3"=>null,"f4"=>null], u.getFields());
      strictEquals([1=>null,2=>"n",3=>null,4=>null], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals("n", u.getValue(2));
      strictEquals(null, u.getValue(3));
      strictEquals(null, u.getValue(4));
      strictEquals(null, u.getValue("f1"));
      strictEquals("n", u.getValue("f2"));
      strictEquals(null, u.getValue("f3"));
      strictEquals(null, u.getValue("f4"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("f3"));
      strictEquals(true, u.isValueChanged("f4"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testRAW(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("RAW", ["i1", "i2"], ["f1", "f2"]);
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=RAW&LS_group=i1%20i2&LS_schema=f1%20f2&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,2");
      ws.onText("U,1,1,a|b");
      ws.onText("U,1,2,c|d");
      ws.onText("U,1,1,A|");
      ws.onText("U,1,2,|D");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(4, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getFields());
      strictEquals([1=>"a",2=>"b"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[1];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getFields());
      strictEquals([1=>"c",2=>"d"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"A"], u.getChangedFields());
      strictEquals([1=>"A"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"A","f2"=>"b"], u.getFields());
      strictEquals([1=>"A",2=>"b"], u.getFieldsByPosition());
      strictEquals("A", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("A", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      u = updates[3];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"D"], u.getChangedFields());
      strictEquals([2=>"D"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"D"], u.getFields());
      strictEquals([1=>"c",2=>"D"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("D", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("D", u.getValue("f2"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals("A", sub.getValue(1, 1));
      strictEquals("b", sub.getValue(1, 2));
      strictEquals("A", sub.getValue(1, "f1"));
      strictEquals("b", sub.getValue(1, "f2"));
      strictEquals("A", sub.getValue("i1", 1));
      strictEquals("b", sub.getValue("i1", 2));
      strictEquals("A", sub.getValue("i1", "f1"));
      strictEquals("b", sub.getValue("i1", "f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testMERGE(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("MERGE", ["i1", "i2"], ["f1", "f2"]);
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=i1%20i2&LS_schema=f1%20f2&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,2");
      ws.onText("U,1,1,a|b");
      ws.onText("U,1,2,c|d");
      ws.onText("U,1,1,A|");
      ws.onText("U,1,2,|D");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(4, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getFields());
      strictEquals([1=>"a",2=>"b"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[1];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getFields());
      strictEquals([1=>"c",2=>"d"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"A"], u.getChangedFields());
      strictEquals([1=>"A"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"A","f2"=>"b"], u.getFields());
      strictEquals([1=>"A",2=>"b"], u.getFieldsByPosition());
      strictEquals("A", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("A", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      u = updates[3];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"D"], u.getChangedFields());
      strictEquals([2=>"D"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"D"], u.getFields());
      strictEquals([1=>"c",2=>"D"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("D", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("D", u.getValue("f2"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals("A", sub.getValue(1, 1));
      strictEquals("b", sub.getValue(1, 2));
      strictEquals("A", sub.getValue(1, "f1"));
      strictEquals("b", sub.getValue(1, "f2"));
      strictEquals("A", sub.getValue("i1", 1));
      strictEquals("b", sub.getValue("i1", 2));
      strictEquals("A", sub.getValue("i1", "f1"));
      strictEquals("b", sub.getValue("i1", "f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testMERGE_NoSnapshot(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("MERGE", ["i1", "i2"], ["f1", "f2"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=MERGE&LS_group=i1%20i2&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,2");
      ws.onText("U,1,1,a|b");
      ws.onText("U,1,2,c|d");
      ws.onText("U,1,1,A|");
      ws.onText("U,1,2,|D");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(4, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getFields());
      strictEquals([1=>"a",2=>"b"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[1];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getFields());
      strictEquals([1=>"c",2=>"d"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"A"], u.getChangedFields());
      strictEquals([1=>"A"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"A","f2"=>"b"], u.getFields());
      strictEquals([1=>"A",2=>"b"], u.getFieldsByPosition());
      strictEquals("A", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("A", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      u = updates[3];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"D"], u.getChangedFields());
      strictEquals([2=>"D"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"D"], u.getFields());
      strictEquals([1=>"c",2=>"D"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("D", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("D", u.getValue("f2"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testDISTINCT(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("DISTINCT", ["i1", "i2"], ["f1", "f2"]);
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=i1%20i2&LS_schema=f1%20f2&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,2");
      ws.onText("U,1,1,a|b");
      ws.onText("U,1,2,c|d");
      ws.onText("EOS,1,1");
      ws.onText("EOS,1,2");
      ws.onText("U,1,1,A|");
      ws.onText("U,1,2,|D");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onEndOfSnapshot i1 1")
    .await("onEndOfSnapshot i2 2")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(4, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getFields());
      strictEquals([1=>"a",2=>"b"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[1];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getFields());
      strictEquals([1=>"c",2=>"d"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"A"], u.getChangedFields());
      strictEquals([1=>"A"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"A","f2"=>"b"], u.getFields());
      strictEquals([1=>"A",2=>"b"], u.getFieldsByPosition());
      strictEquals("A", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("A", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      u = updates[3];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"D"], u.getChangedFields());
      strictEquals([2=>"D"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"D"], u.getFields());
      strictEquals([1=>"c",2=>"D"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("D", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("D", u.getValue("f2"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals("A", sub.getValue(1, 1));
      strictEquals("b", sub.getValue(1, 2));
      strictEquals("A", sub.getValue(1, "f1"));
      strictEquals("b", sub.getValue(1, "f2"));
      strictEquals("A", sub.getValue("i1", 1));
      strictEquals("b", sub.getValue("i1", 2));
      strictEquals("A", sub.getValue("i1", "f1"));
      strictEquals("b", sub.getValue("i1", "f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testDISTINCT_NoSnapshot(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("DISTINCT", ["i1", "i2"], ["f1", "f2"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=DISTINCT&LS_group=i1%20i2&LS_schema=f1%20f2&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,2");
      ws.onText("U,1,1,a|b");
      ws.onText("U,1,2,c|d");
      ws.onText("U,1,1,A|");
      ws.onText("U,1,2,|D");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(4, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b"], u.getFields());
      strictEquals([1=>"a",2=>"b"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[1];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d"], u.getFields());
      strictEquals([1=>"c",2=>"d"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"A"], u.getChangedFields());
      strictEquals([1=>"A"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"A","f2"=>"b"], u.getFields());
      strictEquals([1=>"A",2=>"b"], u.getFieldsByPosition());
      strictEquals("A", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("A", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      u = updates[3];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"D"], u.getChangedFields());
      strictEquals([2=>"D"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"D"], u.getFields());
      strictEquals([1=>"c",2=>"D"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("D", u.getValue(2));
      strictEquals("c", u.getValue("f1"));
      strictEquals("D", u.getValue("f2"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testCOMMAND_ADD(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1", "i2"], ["f1", "f2", "key", "command"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|k1|ADD");
      ws.onText("U,1,2,c|d|k2|ADD");
      ws.onText("U,1,1,|B|k3|");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(3, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
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
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"k2","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d",3=>"k2",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"k2","command"=>"ADD"], u.getFields());
      strictEquals([1=>"c",2=>"d",3=>"k2",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("k2", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals("k2", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"B","key"=>"k3","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"B",3=>"k3",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"B","key"=>"k3","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"B",3=>"k3",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("B", u.getValue(2));
      strictEquals("k3", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("B", u.getValue("f2"));
      strictEquals("k3", u.getValue("key"));
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
      strictEquals("B", sub.getValue(1, 2));
      strictEquals("a", sub.getValue(1, "f1"));
      strictEquals("B", sub.getValue(1, "f2"));
      strictEquals("a", sub.getValue("i1", 1));
      strictEquals("B", sub.getValue("i1", 2));
      strictEquals("a", sub.getValue("i1", "f1"));
      strictEquals("B", sub.getValue("i1", "f2"));
      strictEquals("a", sub.getCommandValue(1, "k3", 1));
      strictEquals("B", sub.getCommandValue(1, "k3", 2));
      strictEquals("a", sub.getCommandValue(1, "k3", "f1"));
      strictEquals("B", sub.getCommandValue(1, "k3", "f2"));
      strictEquals("a", sub.getCommandValue("i1", "k3", 1));
      strictEquals("B", sub.getCommandValue("i1", "k3", 2));
      strictEquals("a", sub.getCommandValue("i1", "k3", "f1"));
      strictEquals("B", sub.getCommandValue("i1", "k3", "f2"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testCOMMAND_UPDATE(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1", "i2"], ["f1", "f2", "key", "command"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|k1|ADD");
      ws.onText("U,1,1,c||k2|");
      ws.onText("U,1,1,a|B|k1|UPDATE");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(3, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
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
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"b","key"=>"k2","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"c",2=>"b",3=>"k2",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"b","key"=>"k2","command"=>"ADD"], u.getFields());
      strictEquals([1=>"c",2=>"b",3=>"k2",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("k2", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("c", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("k2", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"B","command"=>"UPDATE"], u.getChangedFields());
      strictEquals([2=>"B",4=>"UPDATE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"B","key"=>"k1","command"=>"UPDATE"], u.getFields());
      strictEquals([1=>"a",2=>"B",3=>"k1",4=>"UPDATE"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("B", u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("UPDATE", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("B", u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
      strictEquals("UPDATE", u.getValue("command"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testCOMMAND_DELETE(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1", "i2"], ["f1", "f2", "key", "command"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|k1|ADD");
      ws.onText("U,1,1,c|d|k2|");
      ws.onText("U,1,1,x||k1|DELETE");
      ws.onText("U,1,1,c|D|k2|UPDATE");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(4, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
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
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"k2","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d",3=>"k2",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"k2","command"=>"ADD"], u.getFields());
      strictEquals([1=>"c",2=>"d",3=>"k2",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("k2", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals("k2", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>null,"f2"=>null,"command"=>"DELETE"], u.getChangedFields());
      strictEquals([1=>null,2=>null,4=>"DELETE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"k1","command"=>"DELETE"], u.getFields());
      strictEquals([1=>null,2=>null,3=>"k1",4=>"DELETE"], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals(null, u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("DELETE", u.getValue(4));
      strictEquals(null, u.getValue("f1"));
      strictEquals(null, u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
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

  function testCOMMAND_EarlyDELETE(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1", "i2"], ["f1", "f2", "key", "command"]);
      sub.setRequestedSnapshot("no");
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=false&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,x|y|k1|DELETE");
    })
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(1, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"k1","command"=>"DELETE"], u.getChangedFields());
      strictEquals([1=>null,2=>null,3=>"k1",4=>"DELETE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>null,"f2"=>null,"key"=>"k1","command"=>"DELETE"], u.getFields());
      strictEquals([1=>null,2=>null,3=>"k1",4=>"DELETE"], u.getFieldsByPosition());
      strictEquals(null, u.getValue(1));
      strictEquals(null, u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("DELETE", u.getValue(4));
      strictEquals(null, u.getValue("f1"));
      strictEquals(null, u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
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

  function testCOMMAND_EOS(async: utest.Async) {
    exps
    .then(() -> {
      sub = new Subscription("COMMAND", ["i1", "i2"], ["f1", "f2", "key", "command"]);
      sub.setRequestedSnapshot("yes");
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=COMMAND&LS_group=i1%20i2&LS_schema=f1%20f2%20key%20command&LS_snapshot=true&LS_ack=false")
    .then(() -> {
      ws.onText("SUBCMD,1,2,4,3,4");
      ws.onText("U,1,1,a|b|k1|ADD");
      ws.onText("U,1,2,c|d|k2|ADD");
      ws.onText("EOS,1,1");
      ws.onText("EOS,1,2");
      ws.onText("U,1,1,|B||UPDATE");
      ws.onText("U,1,2,C|||UPDATE");
    })
    .await("onItemUpdate")
    .await("onItemUpdate")
    .await("onEndOfSnapshot i1 1")
    .await("onEndOfSnapshot i2 2")
    .await("onItemUpdate")
    .await("onItemUpdate")
    .then(() -> {
      strictEquals(4, updates.length);
      var u = updates[0];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"b","key"=>"k1","command"=>"ADD"], u.getFields());
      strictEquals([1=>"a",2=>"b",3=>"k1",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("b", u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("b", u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
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
      strictEquals(true, u.isSnapshot());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"k2","command"=>"ADD"], u.getChangedFields());
      strictEquals([1=>"c",2=>"d",3=>"k2",4=>"ADD"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"c","f2"=>"d","key"=>"k2","command"=>"ADD"], u.getFields());
      strictEquals([1=>"c",2=>"d",3=>"k2",4=>"ADD"], u.getFieldsByPosition());
      strictEquals("c", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("k2", u.getValue(3));
      strictEquals("ADD", u.getValue(4));
      strictEquals("c", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals("k2", u.getValue("key"));
      strictEquals("ADD", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(true, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(true, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      u = updates[2];
      strictEquals("i1", u.getItemName());
      strictEquals(1, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f2"=>"B","command"=>"UPDATE"], u.getChangedFields());
      strictEquals([2=>"B",4=>"UPDATE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"a","f2"=>"B","key"=>"k1","command"=>"UPDATE"], u.getFields());
      strictEquals([1=>"a",2=>"B",3=>"k1",4=>"UPDATE"], u.getFieldsByPosition());
      strictEquals("a", u.getValue(1));
      strictEquals("B", u.getValue(2));
      strictEquals("k1", u.getValue(3));
      strictEquals("UPDATE", u.getValue(4));
      strictEquals("a", u.getValue("f1"));
      strictEquals("B", u.getValue("f2"));
      strictEquals("k1", u.getValue("key"));
      strictEquals("UPDATE", u.getValue("command"));
      strictEquals(false, u.isValueChanged(1));
      strictEquals(true, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(false, u.isValueChanged("f1"));
      strictEquals(true, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
      u = updates[3];
      strictEquals("i2", u.getItemName());
      strictEquals(2, u.getItemPos());
      strictEquals(false, u.isSnapshot());
      strictEquals(["f1"=>"C","command"=>"UPDATE"], u.getChangedFields());
      strictEquals([1=>"C",4=>"UPDATE"], u.getChangedFieldsByPosition());
      strictEquals(["f1"=>"C","f2"=>"d","key"=>"k2","command"=>"UPDATE"], u.getFields());
      strictEquals([1=>"C",2=>"d",3=>"k2",4=>"UPDATE"], u.getFieldsByPosition());
      strictEquals("C", u.getValue(1));
      strictEquals("d", u.getValue(2));
      strictEquals("k2", u.getValue(3));
      strictEquals("UPDATE", u.getValue(4));
      strictEquals("C", u.getValue("f1"));
      strictEquals("d", u.getValue("f2"));
      strictEquals("k2", u.getValue("key"));
      strictEquals("UPDATE", u.getValue("command"));
      strictEquals(true, u.isValueChanged(1));
      strictEquals(false, u.isValueChanged(2));
      strictEquals(false, u.isValueChanged(3));
      strictEquals(true, u.isValueChanged(4));
      strictEquals(true, u.isValueChanged("f1"));
      strictEquals(false, u.isValueChanged("f2"));
      strictEquals(false, u.isValueChanged("key"));
      strictEquals(true, u.isValueChanged("command"));
    })
    .then(() -> async.completed())
    .verify();
  }

  function testDisconnectAndReconnect(async: utest.Async) {
    exps
    .then(() -> {
      subListener._onSubscription = () -> exps.signal("onSubscription");
      subListener._onUnsubscription = () -> exps.signal("onUnsubscription");
      sub = new Subscription("RAW", ["i1", "i2"], ["f1", "f2"]);
      sub.addListener(subListener);
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
    .await("control\r\nLS_reqId=1&LS_op=add&LS_subId=1&LS_mode=RAW&LS_group=i1%20i2&LS_schema=f1%20f2&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,2");
    })
    .await("onSubscription")
    .then(() -> client.disconnect())
    .await("control\r\nLS_reqId=2&LS_op=destroy&LS_close_socket=true&LS_cause=api")
    .await("ws.dispose")
    .await("onUnsubscription")
    .then(() -> client.connect())
    .await("ws.init http://server/lightstreamer")
    .then(() -> ws.onOpen())
    .await("wsok")
    .await("create_session\r\nLS_keepalive_millis=5000&LS_adapter_set=TEST&LS_cid=mgQkwtwdysogQz2BJ4Ji%20kOj2Bg&LS_send_sync=false&LS_cause=api")
    .then(() -> {
      ws.onText("WSOK");
      ws.onText("CONOK,sid,70000,5000,*");
    })
    .await("control\r\nLS_reqId=3&LS_op=add&LS_subId=1&LS_mode=RAW&LS_group=i1%20i2&LS_schema=f1%20f2&LS_ack=false")
    .then(() -> {
      ws.onText("SUBOK,1,2,2");
    })
    .await("onSubscription")
    .then(() -> async.completed())
    .verify();
  }
}