package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;

class TestMpnSubscription extends utest.Test {
  var sub: MpnSubscription;

  function setup() {
    sub = new MpnSubscription("MERGE", ["i1"], ["f1"]);
  }

  function testCtor() {
    equals("MERGE", sub.getMode());
    strictSame(["i1"], sub.getItems());
    strictSame(["f1"], sub.getFields());

    raisesEx(() -> new MpnSubscription("xxx", ["i1"], ["f1"]), IllegalArgumentException, "The given value is not a valid subscription mode. Admitted values are MERGE, DISTINCT");

    raisesEx(() -> new MpnSubscription("MERGE", [], ["f1"]), IllegalArgumentException, "Item List is empty");
    raisesEx(() -> new MpnSubscription("MERGE", [""], ["f1"]), IllegalArgumentException, "Item List is invalid");

    raisesEx(() -> new MpnSubscription("MERGE", ["i1"], []), IllegalArgumentException, "Field List is empty");
    raisesEx(() -> new MpnSubscription("MERGE", ["i1"], [""]), IllegalArgumentException, "Field List is invalid");
  }

  function testTrigger() {
    equals(null, sub.getTriggerExpression());

    sub.setTriggerExpression("a>0");
    equals("a>0", sub.getTriggerExpression());
    sub.setTriggerExpression(null);
    equals(null, sub.getTriggerExpression());
  }

  function testNotificationFormat() {
    equals(null, sub.getNotificationFormat());

    sub.setNotificationFormat("{a:0}");
    equals("{a:0}", sub.getNotificationFormat());
    sub.setNotificationFormat(null);
    equals(null, sub.getNotificationFormat());
  }

  function testIsActive() {
    equals(false, sub.isActive());
  }

  function testIsSubscribed() {
    equals(false, sub.isSubscribed());
  }

  function testIsTriggered() {
    equals(false, sub.isTriggered());
  }

  function testGetStatus() {
    equals("UNKNOWN", sub.getStatus());
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

  function testRequestedMaxFrequency() {
    equals(null, sub.getRequestedMaxFrequency());

    sub.setRequestedMaxFrequency("unlimited");
    equals("unlimited", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency("100");
    equals("100", sub.getRequestedMaxFrequency());
    sub.setRequestedMaxFrequency(null);
    equals(null, sub.getRequestedMaxFrequency());

    raisesEx(() -> sub.setRequestedMaxFrequency("xxx"), IllegalArgumentException, "The given value is not valid for this setting; use null, 'unlimited' or a positive number instead");
  }
}