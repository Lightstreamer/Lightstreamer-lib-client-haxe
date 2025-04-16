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

class TestConnectionOptions extends utest.Test {
  var options = new LightstreamerClient("http://example.com", "TEST").connectionOptions;

  function testContentLength() {
    equals(50000000, options.getContentLength());

    options.setContentLength(1000);
    equals(1000, options.getContentLength());

    raises(() -> options.setContentLength(0), IllegalArgumentException);
  }

  function testFirstRetryMaxDelay() {
    equals(100, options.getFirstRetryMaxDelay());

    options.setFirstRetryMaxDelay(1000);
    equals(1000, options.getFirstRetryMaxDelay());

    raises(() -> options.setFirstRetryMaxDelay(0), IllegalArgumentException);
  }

  function testForcedTransport() {
    equals(null, options.getForcedTransport());

    options.setForcedTransport("WS");
    equals("WS", options.getForcedTransport());
    options.setForcedTransport("WS-STREAMING");
    equals("WS-STREAMING", options.getForcedTransport());
    options.setForcedTransport("WS-POLLING");
    equals("WS-POLLING", options.getForcedTransport());
    options.setForcedTransport("HTTP");
    equals("HTTP", options.getForcedTransport());
    options.setForcedTransport("HTTP-STREAMING");
    equals("HTTP-STREAMING", options.getForcedTransport());
    options.setForcedTransport("HTTP-POLLING");
    equals("HTTP-POLLING", options.getForcedTransport());
    options.setForcedTransport(null);
    equals(null, options.getForcedTransport());

    raises(() -> options.setForcedTransport("foo"), IllegalArgumentException);
  }

  function testHttpExtraHeaders() {
    equals(null, options.getHttpExtraHeaders());

    options.setHttpExtraHeaders(["Foo"=>"bar"]);
    strictSame(["Foo"=>"bar"], options.getHttpExtraHeaders());
    options.setHttpExtraHeaders(([]:Map<String,String>));
    strictSame(([]:Map<String,String>), options.getHttpExtraHeaders());
    options.setHttpExtraHeaders(null);
    equals(null, options.getHttpExtraHeaders());
  }

  function testIdleTimeout() {
    equals(19000, options.getIdleTimeout());

    options.setIdleTimeout(1000);
    equals(1000, options.getIdleTimeout());
    options.setIdleTimeout(0);
    equals(0, options.getIdleTimeout());

    raises(() -> options.setIdleTimeout(-1), IllegalArgumentException);
  }

  function testKeepaliveInterval() {
    equals(0, options.getKeepaliveInterval());

    options.setKeepaliveInterval(1000);
    equals(1000, options.getKeepaliveInterval());
    options.setKeepaliveInterval(0);
    equals(0, options.getKeepaliveInterval());

    raises(() -> options.setKeepaliveInterval(-1), IllegalArgumentException);
  }

  function testRequestedMaxBandwidth() {
    equals("unlimited", options.getRequestedMaxBandwidth());

    options.setRequestedMaxBandwidth("100");
    equals("100", options.getRequestedMaxBandwidth());
    options.setRequestedMaxBandwidth("UNLIMITED");
    equals("unlimited", options.getRequestedMaxBandwidth());

    raises(() -> options.setRequestedMaxBandwidth("foo"), IllegalArgumentException);
    raises(() -> options.setRequestedMaxBandwidth("0"), IllegalArgumentException);
    raises(() -> options.setRequestedMaxBandwidth("-1"), IllegalArgumentException);
  }

  function testRealMaxBandwidth() {
    equals(null, options.getRealMaxBandwidth());
  }

  function testPollingInterval() {
    equals(0, options.getPollingInterval());

    options.setPollingInterval(100);
    equals(100, options.getPollingInterval());
    options.setPollingInterval(0);
    equals(0, options.getPollingInterval());

    raises(() -> options.setPollingInterval(-1), IllegalArgumentException);
  }

  function testReconnectTimeout() {
    equals(3000, options.getReconnectTimeout());

    options.setReconnectTimeout(1000);
    equals(1000, options.getReconnectTimeout());

    raises(() -> options.setReconnectTimeout(0), IllegalArgumentException);
    raises(() -> options.setReconnectTimeout(-1), IllegalArgumentException);
  }

  function testRetryDelay() {
    equals(4000, options.getRetryDelay());

    options.setRetryDelay(1000);
    equals(1000, options.getRetryDelay());

    raises(() -> options.setRetryDelay(0), IllegalArgumentException);
    raises(() -> options.setRetryDelay(-1), IllegalArgumentException);
  }

  function testReverseHeartbeatInterval() {
    equals(0, options.getReverseHeartbeatInterval());

    options.setReverseHeartbeatInterval(1000);
    equals(1000, options.getReverseHeartbeatInterval());
    options.setReverseHeartbeatInterval(0);
    equals(0, options.getReverseHeartbeatInterval());

    raises(() -> options.setReverseHeartbeatInterval(-1), IllegalArgumentException);
  }

  function testSessionRecoveryTimeout() {
    equals(15000, options.getSessionRecoveryTimeout());

    options.setSessionRecoveryTimeout(1000);
    equals(1000, options.getSessionRecoveryTimeout());
    options.setSessionRecoveryTimeout(0);
    equals(0, options.getSessionRecoveryTimeout());

    raises(() -> options.setSessionRecoveryTimeout(-1), IllegalArgumentException);
  }

  function testStalledTimeout() {
    equals(2000, options.getStalledTimeout());

    options.setStalledTimeout(1000);
    equals(1000, options.getStalledTimeout());

    raises(() -> options.setStalledTimeout(0), IllegalArgumentException);
    raises(() -> options.setStalledTimeout(-1), IllegalArgumentException);
  }

  function testHttpExtraHeadersOnSessionCreationOnly() {
    equals(false, options.isHttpExtraHeadersOnSessionCreationOnly());

    options.setHttpExtraHeadersOnSessionCreationOnly(true);
    equals(true, options.isHttpExtraHeadersOnSessionCreationOnly());
  }

  function testServerInstanceAddressIgnored() {
    equals(false, options.isServerInstanceAddressIgnored());

    options.setServerInstanceAddressIgnored(true);
    equals(true, options.isServerInstanceAddressIgnored());
  }

  function testSlowingEnabled() {
    equals(false, options.isSlowingEnabled());

    options.setSlowingEnabled(true);
    equals(true, options.isSlowingEnabled());
  }
}