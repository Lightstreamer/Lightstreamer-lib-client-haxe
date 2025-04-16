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
package com.lightstreamer.client;

import com.lightstreamer.client.BaseListener;

class TestOkHttp extends utest.Test {
  
  @:timeout(300000)
  function testLongRequest(async: utest.Async) {
    var client = new LightstreamerClient("http://localtest.me:8080", "TEST");
    // client.connectionOptions.setSessionRecoveryTimeout(0);
    // client.connectionOptions.setForcedTransport("HTTP");
    // client.connectionOptions.setForcedTransport("WS");
    var listener = new BaseClientListener();
    listener._onStatusChange = (status) -> {
      trace(status);
    };
    client.addListener(listener);
    var subListener = new BaseSubscriptionListener();
    subListener._onSubscriptionError = (code, msg) -> {
      trace(code, msg);
    };
    var sub = new Subscription("MERGE", [for (_ in 0...8000) "count"], ["count"]);
    sub.setDataAdapter("COUNT");
    sub.addListener(subListener);
    client.subscribe(sub);
    client.connect();
  }
}