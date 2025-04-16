/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.client.mpn;

import utils.AndroidTools.appContext;
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