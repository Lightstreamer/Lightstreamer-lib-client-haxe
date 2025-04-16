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

import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;

class TestConnectionDetails extends utest.Test {
  var details = new LightstreamerClient("http://example.com", "TEST").connectionDetails;

  function testServerAddress() {
    equals("http://example.com", details.getServerAddress());

    details.setServerAddress("https://example.com:8080/ls");
    equals("https://example.com:8080/ls", details.getServerAddress());

    raises(() -> details.setServerAddress("example.com"), IllegalArgumentException);
    raises(() -> details.setServerAddress("tcp://example.com"), IllegalArgumentException);
  }

  function testAdapterSet() {
    equals("TEST", details.getAdapterSet());

    details.setAdapterSet("DEMO");
    equals("DEMO", details.getAdapterSet());
  }

  function testUser() {
    equals(null, details.getUser());

    details.setUser("user");
    equals("user", details.getUser());
  }
}