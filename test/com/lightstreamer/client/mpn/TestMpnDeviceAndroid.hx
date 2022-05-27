package com.lightstreamer.client.mpn;

import AndroidTools.appContext;
import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;
import com.lightstreamer.client.mpn.AndroidTools;

class TestMpnDeviceAndroid extends utest.Test {
  var dev: MpnDevice;

  function setup() {
    dev = new MpnDevice(appContext, "tok");
  }

  function testCtor() {
    raisesEx(() -> new MpnDevice(null, "tok"), IllegalArgumentException, "Please specify a valid appContext");
    raisesEx(() -> new MpnDevice(appContext, null), IllegalArgumentException, "Please specify a valid token");
  }

  function testApplicationId() {
    equals("com.example.testapp", dev.getApplicationId());
  }

  function testToken() {
    equals("tok", dev.getDeviceToken());
  }

  function testPrevDeviceToken() {
    AndroidTools.writeTokenToSharedPreferences(appContext, "prevTok");

    dev = new MpnDevice(appContext, "tok");
    equals("prevTok", dev.getPreviousDeviceToken());
    equals("tok", AndroidTools.readTokenFromSharedPreferences(appContext));
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