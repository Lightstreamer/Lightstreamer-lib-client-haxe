package com.lightstreamer.client;

import com.lightstreamer.client.NativeTypes.IllegalStateException;
import com.lightstreamer.client.NativeTypes.IllegalArgumentException;

class TestSubscription extends utest.Test {
  var sub = new Subscription("MERGE", ["i1"], ["f1"]);

  function testCtor() {
    var sub = new Subscription("MERGE", ["i1"], ["f1"]);
    Assert.equals("MERGE", sub.getMode());
    Assert.strictSame(["i1"], sub.getItems());
    Assert.strictSame(["f1"], sub.getFields());

    Assert.raisesEx(() -> new Subscription("xxx", ["i1"], ["f1"]), IllegalArgumentException, "The given value is not a valid subscription mode. Admitted values are MERGE, DISTINCT, RAW, COMMAND");

    Assert.raisesEx(() -> new Subscription("MERGE", [], ["f1"]), IllegalArgumentException, "Item List is empty");
    Assert.raisesEx(() -> new Subscription("MERGE", [""], ["f1"]), IllegalArgumentException, "Item List is invalid");

    Assert.raisesEx(() -> new Subscription("MERGE", ["i1"], []), IllegalArgumentException, "Field List is empty");
    Assert.raisesEx(() -> new Subscription("MERGE", ["i1"], [""]), IllegalArgumentException, "Field List is invalid");

    Assert.raisesEx(() -> new Subscription("COMMAND", ["i1"], ["f1"]), IllegalArgumentException, "Field 'key' is missing");
    Assert.raisesEx(() -> new Subscription("COMMAND", ["i1"], ["key"]), IllegalArgumentException, "Field 'command' is missing");
  }

  function testIsActive() {
    Assert.equals(false, sub.isActive());
  }

  function testIsSubscribed() {
    Assert.equals(false, sub.isSubscribed());
  }

  function testDataAdapter() {
    Assert.equals(null, sub.getDataAdapter());

    sub.setDataAdapter("adapter");
    Assert.equals("adapter", sub.getDataAdapter());
    sub.setDataAdapter(null);
    Assert.equals(null, sub.getDataAdapter());

    Assert.raisesEx(() -> sub.setDataAdapter(""), IllegalArgumentException, "The value is empty");
  }

  function testMode() {
    Assert.equals("MERGE", sub.getMode());
  }

  function testItems() {
    Assert.strictSame(["i1"], sub.getItems());

    sub.setItems(["i1", "i2"]);
    Assert.strictSame(["i1", "i2"], sub.getItems());

    Assert.raisesEx(() -> sub.setItems([]), IllegalArgumentException, "Item List is empty");
    Assert.raisesEx(() -> sub.setItems([""]), IllegalArgumentException, "Item List is invalid");
  }

  function testItemGroup() {
    Assert.equals(null, sub.getItemGroup());

    sub.setItemGroup("grp");
    Assert.equals("grp", sub.getItemGroup());
  }

  function testFields() {
    Assert.strictSame(["f1"], sub.getFields());

    sub.setFields(["f1", "f2"]);
    Assert.strictSame(["f1", "f2"], sub.getFields());

    Assert.raisesEx(() -> sub.setFields([]), IllegalArgumentException, "Field List is empty");
    Assert.raisesEx(() -> sub.setFields([""]), IllegalArgumentException, "Field List is invalid");
  }

  function testFieldSchema() {
    Assert.equals(null, sub.getFieldSchema());

    sub.setFieldSchema("scm");
    Assert.equals("scm", sub.getFieldSchema());
  }

  function testRequestedBufferSize() {
    Assert.equals(null, sub.getRequestedBufferSize());

    sub.setRequestedBufferSize("unlimited");
    Assert.equals("unlimited", sub.getRequestedBufferSize());
    sub.setRequestedBufferSize("100");
    Assert.equals("100", sub.getRequestedBufferSize());
    sub.setRequestedBufferSize(null);
    Assert.equals(null, sub.getRequestedBufferSize());

    Assert.raises(() -> sub.setRequestedBufferSize("xxx"), IllegalArgumentException);
  }

  function testRequestedSnapshot() {
    Assert.equals("yes", sub.getRequestedSnapshot());

    sub.setRequestedSnapshot("no");
    Assert.equals("no", sub.getRequestedSnapshot());
    sub.setRequestedSnapshot("yes");
    Assert.equals("yes", sub.getRequestedSnapshot());
    sub.setRequestedSnapshot(null);
    Assert.equals(null, sub.getRequestedSnapshot());

    Assert.raisesEx(() -> sub.setRequestedSnapshot("xxx"), IllegalArgumentException, "The given value is not valid for this setting; use null, 'yes', 'no' or a positive number instead");
    Assert.raisesEx(() -> sub.setRequestedSnapshot("100"), IllegalArgumentException, "Snapshot length is not permitted if MERGE or COMMAND was specified as mode");
  }

  function testRequestedMaxFrequency() {
    Assert.equals(null, sub.getRequestedMaxFrequency());

    sub.setRequestedMaxFrequency("unlimited");
    Assert.equals("unlimited", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency("unfiltered");
    Assert.equals("unfiltered", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency("100");
    Assert.equals("100", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency(null);
    Assert.equals(null, sub.getRequestedMaxFrequency());

    Assert.raisesEx(() -> sub.setRequestedMaxFrequency("xxx"), IllegalArgumentException, "The given value is not valid for this setting; use null, 'unlimited', 'unfiltered' or a positive number instead");
  }

  function testSelector() {
    Assert.equals(null, sub.getSelector());

    sub.setSelector("sel");
    Assert.equals("sel", sub.getSelector());
  }

  function testCommandPosition() {
    Assert.equals(null, sub.getCommandPosition());
  }

  function testKeyPosition() {
    Assert.equals(null, sub.getKeyPosition());
  }

  function testCommandSecondLevelAdapter() {
    Assert.equals(null, sub.getCommandSecondLevelDataAdapter());

    Assert.raisesEx(() -> sub.setCommandSecondLevelDataAdapter("adapter2"), IllegalStateException, "The operation is only available on COMMAND Subscriptions");

    var sub = new Subscription("COMMAND", ["i1"], ["key", "command"]);
    sub.setCommandSecondLevelDataAdapter("adapter2");
    Assert.equals("adapter2", sub.getCommandSecondLevelDataAdapter());
  }

  function testCommandSecondLevelFields() {
    Assert.equals(null, sub.getCommandSecondLevelFields());

    var sub = new Subscription("COMMAND", ["i1"], ["key", "command"]);
    sub.setCommandSecondLevelFields(["f1", "f2"]);
    Assert.strictSame(["f1", "f2"], sub.getCommandSecondLevelFields());

    Assert.raisesEx(() -> sub.setCommandSecondLevelFields([]), IllegalArgumentException, "Field List is empty");
    Assert.raisesEx(() -> sub.setCommandSecondLevelFields([""]), IllegalArgumentException, "Field List is invalid");
  }

  function testCommandSecondLevelFieldSchema() {
    Assert.equals(null, sub.getCommandSecondLevelFieldSchema());

    var sub = new Subscription("COMMAND", ["i1"], ["key", "command"]);
    sub.setCommandSecondLevelFieldSchema("scm2");
    Assert.equals("scm2", sub.getCommandSecondLevelFieldSchema());
  }
}