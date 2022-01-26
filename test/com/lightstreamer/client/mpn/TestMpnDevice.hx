package com.lightstreamer.client.mpn;

import com.lightstreamer.client.NativeTypes.IllegalArgumentException;

class TestMpnDevice extends utest.Test {
  var dev: MpnDevice;

  function setup() {
    dev = new MpnDevice("tok", "myapp", "Google");
  }

  function testCtor() {
    raisesEx(() -> new MpnDevice(null, "myapp", "Google"), IllegalArgumentException, "Please specify a valid device token");
    raisesEx(() -> new MpnDevice("tok", null, "Google"), IllegalArgumentException, "Please specify a valid application ID");
    raisesEx(() -> new MpnDevice("tok", "myapp", null), IllegalArgumentException, "Please specify a valid platform: Google or Apple");
    raisesEx(() -> new MpnDevice("tok", "myapp", "xxx"), IllegalArgumentException, "Please specify a valid platform: Google or Apple");
  }

  function testPlatform() {
    dev = new MpnDevice("tok", "myapp", "Google");
    equals("Google", dev.getPlatform());

    dev = new MpnDevice("tok", "myapp", "Apple");
    equals("Apple", dev.getPlatform());
  }

  function testApplicationId() {
    equals("myapp", dev.getApplicationId());
  }

  function testToken() {
    equals("tok", dev.getDeviceToken());
  }

  function testPrevDeviceToken() {
    js.Browser.getLocalStorage().setItem("com.lightstreamer.mpn.device_token", "prevTok");

    dev = new MpnDevice("tok", "myapp", "Google");
    equals("prevTok", dev.getPreviousDeviceToken());
    equals("tok", js.Browser.getLocalStorage().getItem("com.lightstreamer.mpn.device_token"));
  }

  function testDeviceId() {
    equals(null, dev.getDeviceId());
  }

  function testRegistered() {
    equals(false, dev.isRegistered());
  }

  function testSuspended() {
    equals(false, dev.isSuspended());
  }

  function testStatus() {
    equals("UNKNOWN", dev.getStatus());
  }

  function testStatusTimestamp() {
    equals(0, dev.getStatusTimestamp());
  }
}