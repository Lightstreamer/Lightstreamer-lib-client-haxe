package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;

class TestSubscription extends utest.Test {
  var sub: Subscription;

  function setup() {
    sub = new Subscription("MERGE", ["i1"], ["f1"]);
  }

  function testCtor() {
    equals("MERGE", sub.getMode());
    strictSame(["i1"], sub.getItems());
    strictSame(["f1"], sub.getFields());

    raisesEx(() -> new Subscription("xxx", ["i1"], ["f1"]), IllegalArgumentException, "The given value is not a valid subscription mode. Admitted values are MERGE, DISTINCT, RAW, COMMAND");

    raisesEx(() -> new Subscription("MERGE", [], ["f1"]), IllegalArgumentException, "Item List is empty");
    raisesEx(() -> new Subscription("MERGE", [""], ["f1"]), IllegalArgumentException, "Item List is invalid");

    raisesEx(() -> new Subscription("MERGE", ["i1"], []), IllegalArgumentException, "Field List is empty");
    raisesEx(() -> new Subscription("MERGE", ["i1"], [""]), IllegalArgumentException, "Field List is invalid");

    raisesEx(() -> new Subscription("COMMAND", ["i1"], ["f1"]), IllegalArgumentException, "Field 'key' is missing");
    raisesEx(() -> new Subscription("COMMAND", ["i1"], ["key"]), IllegalArgumentException, "Field 'command' is missing");
  }

  function testIsActive() {
    equals(false, sub.isActive());
  }

  function testIsSubscribed() {
    equals(false, sub.isSubscribed());
  }

  function testDataAdapter() {
    equals(null, sub.getDataAdapter());

    sub.setDataAdapter("adapter");
    equals("adapter", sub.getDataAdapter());
    sub.setDataAdapter(null);
    equals(null, sub.getDataAdapter());

    raisesEx(() -> sub.setDataAdapter(""), IllegalArgumentException, "The value is empty");
  }

  function testMode() {
    equals("MERGE", sub.getMode());
  }

  function testItems() {
    strictSame(["i1"], sub.getItems());

    sub.setItems(["i1", "i2"]);
    strictSame(["i1", "i2"], sub.getItems());

    raisesEx(() -> sub.setItems([]), IllegalArgumentException, "Item List is empty");
    raisesEx(() -> sub.setItems([""]), IllegalArgumentException, "Item List is invalid");

    sub.setItems(["123i"]);
    strictSame(["123i"], sub.getItems());

    raisesEx(() -> sub.setItems(["123"]), IllegalArgumentException, "Item List is invalid");
  }

  function testItemGroup() {
    equals(null, sub.getItemGroup());

    sub.setItemGroup("grp");
    equals("grp", sub.getItemGroup());
  }

  function testFields() {
    strictSame(["f1"], sub.getFields());

    sub.setFields(["f1", "f2"]);
    strictSame(["f1", "f2"], sub.getFields());

    raisesEx(() -> sub.setFields([]), IllegalArgumentException, "Field List is empty");
    raisesEx(() -> sub.setFields([""]), IllegalArgumentException, "Field List is invalid");
  }

  function testFieldSchema() {
    equals(null, sub.getFieldSchema());

    sub.setFieldSchema("scm");
    equals("scm", sub.getFieldSchema());
  }

  function testRequestedBufferSize() {
    equals(null, sub.getRequestedBufferSize());

    sub.setRequestedBufferSize("unlimited");
    equals("unlimited", sub.getRequestedBufferSize());
    sub.setRequestedBufferSize("100");
    equals("100", sub.getRequestedBufferSize());
    sub.setRequestedBufferSize(null);
    equals(null, sub.getRequestedBufferSize());

    raises(() -> sub.setRequestedBufferSize("xxx"), IllegalArgumentException);
  }

  function testRequestedSnapshot() {
    equals("yes", sub.getRequestedSnapshot());

    sub.setRequestedSnapshot("no");
    equals("no", sub.getRequestedSnapshot());
    sub.setRequestedSnapshot("yes");
    equals("yes", sub.getRequestedSnapshot());
    sub.setRequestedSnapshot(null);
    equals(null, sub.getRequestedSnapshot());

    raisesEx(() -> sub.setRequestedSnapshot("xxx"), IllegalArgumentException, "The given value is not valid for this setting; use null, 'yes', 'no' or a positive number instead");
    raisesEx(() -> sub.setRequestedSnapshot("100"), IllegalArgumentException, "Snapshot length is not permitted if MERGE or COMMAND was specified as mode");
  }

  function testRequestedMaxFrequency() {
    equals(null, sub.getRequestedMaxFrequency());

    sub.setRequestedMaxFrequency("unlimited");
    equals("unlimited", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency("unfiltered");
    equals("unfiltered", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency("100");
    equals("100", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency(null);
    equals(null, sub.getRequestedMaxFrequency());

    raisesEx(() -> sub.setRequestedMaxFrequency("xxx"), IllegalArgumentException, "The given value is not valid for this setting; use null, 'unlimited', 'unfiltered' or a positive number instead");
  }

  function testSelector() {
    equals(null, sub.getSelector());

    sub.setSelector("sel");
    equals("sel", sub.getSelector());
  }

  function testCommandPosition() {
    raisesEx(() -> sub.getCommandPosition(), IllegalArgumentException, "This method can only be used on COMMAND subscriptions");
  }

  function testKeyPosition() {
    raisesEx(() -> sub.getKeyPosition(), IllegalArgumentException, "This method can only be used on COMMAND subscriptions");
  }

  function testCommandSecondLevelAdapter() {
    equals(null, sub.getCommandSecondLevelDataAdapter());

    raisesEx(() -> sub.setCommandSecondLevelDataAdapter("adapter2"), IllegalStateException, "This method can only be used on COMMAND subscriptions");

    var sub = new Subscription("COMMAND", ["i1"], ["key", "command"]);
    sub.setCommandSecondLevelDataAdapter("adapter2");
    equals("adapter2", sub.getCommandSecondLevelDataAdapter());
  }

  function testCommandSecondLevelFields() {
    equals(null, sub.getCommandSecondLevelFields());

    var sub = new Subscription("COMMAND", ["i1"], ["key", "command"]);
    sub.setCommandSecondLevelFields(["f1", "f2"]);
    strictSame(["f1", "f2"], sub.getCommandSecondLevelFields());

    raisesEx(() -> sub.setCommandSecondLevelFields([]), IllegalArgumentException, "Field List is empty");
    raisesEx(() -> sub.setCommandSecondLevelFields([""]), IllegalArgumentException, "Field List is invalid");
  }

  function testCommandSecondLevelFieldSchema() {
    equals(null, sub.getCommandSecondLevelFieldSchema());

    var sub = new Subscription("COMMAND", ["i1"], ["key", "command"]);
    sub.setCommandSecondLevelFieldSchema("scm2");
    equals("scm2", sub.getCommandSecondLevelFieldSchema());
  }
}