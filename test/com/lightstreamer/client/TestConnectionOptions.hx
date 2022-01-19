package com.lightstreamer.client;

import com.lightstreamer.client.NativeTypes.IllegalArgumentException;
import utest.Assert;
using TestTools;

class TestConnectionOptions extends utest.Test {
  var options = new LightstreamerClient("http://example.com", "TEST").connectionOptions;

  function testContentLength() {
    Assert.equals(50000000, options.getContentLength());

    options.setContentLength(1000);
    Assert.equals(1000, options.getContentLength());

    Assert.raises(() -> options.setContentLength(0), IllegalArgumentException);
  }

  function testFirstRetryMaxDelay() {
    Assert.equals(100, options.getFirstRetryMaxDelay());

    options.setFirstRetryMaxDelay(1000);
    Assert.equals(1000, options.getFirstRetryMaxDelay());

    Assert.raises(() -> options.setFirstRetryMaxDelay(0), IllegalArgumentException);
  }

  function testForcedTransport() {
    Assert.equals(null, options.getForcedTransport());

    options.setForcedTransport("WS");
    Assert.equals("WS", options.getForcedTransport());
    options.setForcedTransport("WS-STREAMING");
    Assert.equals("WS-STREAMING", options.getForcedTransport());
    options.setForcedTransport("WS-POLLING");
    Assert.equals("WS-POLLING", options.getForcedTransport());
    options.setForcedTransport("HTTP");
    Assert.equals("HTTP", options.getForcedTransport());
    options.setForcedTransport("HTTP-STREAMING");
    Assert.equals("HTTP-STREAMING", options.getForcedTransport());
    options.setForcedTransport("HTTP-POLLING");
    Assert.equals("HTTP-POLLING", options.getForcedTransport());
    options.setForcedTransport(null);
    Assert.equals(null, options.getForcedTransport());

    Assert.raises(() -> options.setForcedTransport("foo"), IllegalArgumentException);
  }

  function testHttpExtraHeaders() {
    Assert.equals(null, options.getHttpExtraHeaders());

    options.setHttpExtraHeaders(["Foo"=>"bar"]);
    Assert.strictSame(["Foo"=>"bar"], options.getHttpExtraHeaders());
    options.setHttpExtraHeaders(([]:Map<String,String>));
    Assert.strictSame(([]:Map<String,String>), options.getHttpExtraHeaders());
    options.setHttpExtraHeaders(null);
    Assert.equals(null, options.getHttpExtraHeaders());
  }

  function testIdleTimeout() {
    Assert.equals(19000, options.getIdleTimeout());

    options.setIdleTimeout(1000);
    Assert.equals(1000, options.getIdleTimeout());
    options.setIdleTimeout(0);
    Assert.equals(0, options.getIdleTimeout());

    Assert.raises(() -> options.setIdleTimeout(-1), IllegalArgumentException);
  }

  function testKeepaliveInterval() {
    Assert.equals(0, options.getKeepaliveInterval());

    options.setKeepaliveInterval(1000);
    Assert.equals(1000, options.getKeepaliveInterval());
    options.setKeepaliveInterval(0);
    Assert.equals(0, options.getKeepaliveInterval());

    Assert.raises(() -> options.setKeepaliveInterval(-1), IllegalArgumentException);
  }

  function testRequestedMaxBandwidth() {
    Assert.equals("unlimited", options.getRequestedMaxBandwidth());

    options.setRequestedMaxBandwidth("100");
    Assert.equals("100", options.getRequestedMaxBandwidth());
    options.setRequestedMaxBandwidth("UNLIMITED");
    Assert.equals("unlimited", options.getRequestedMaxBandwidth());

    Assert.raises(() -> options.setRequestedMaxBandwidth("foo"), IllegalArgumentException);
    Assert.raises(() -> options.setRequestedMaxBandwidth("0"), IllegalArgumentException);
    Assert.raises(() -> options.setRequestedMaxBandwidth("-1"), IllegalArgumentException);
  }

  function testRealMaxBandwidth() {
    Assert.equals(null, options.getRealMaxBandwidth());
  }

  function testPollingInterval() {
    Assert.equals(0, options.getPollingInterval());

    options.setPollingInterval(100);
    Assert.equals(100, options.getPollingInterval());
    options.setPollingInterval(0);
    Assert.equals(0, options.getPollingInterval());

    Assert.raises(() -> options.setPollingInterval(-1), IllegalArgumentException);
  }

  function testReconnectTimeout() {
    Assert.equals(3000, options.getReconnectTimeout());

    options.setReconnectTimeout(1000);
    Assert.equals(1000, options.getReconnectTimeout());

    Assert.raises(() -> options.setReconnectTimeout(0), IllegalArgumentException);
    Assert.raises(() -> options.setReconnectTimeout(-1), IllegalArgumentException);
  }

  function testRetryDelay() {
    Assert.equals(4000, options.getRetryDelay());

    options.setRetryDelay(1000);
    Assert.equals(1000, options.getRetryDelay());

    Assert.raises(() -> options.setRetryDelay(0), IllegalArgumentException);
    Assert.raises(() -> options.setRetryDelay(-1), IllegalArgumentException);
  }

  function testReverseHeartbeatInterval() {
    Assert.equals(0, options.getReverseHeartbeatInterval());

    options.setReverseHeartbeatInterval(1000);
    Assert.equals(1000, options.getReverseHeartbeatInterval());
    options.setReverseHeartbeatInterval(0);
    Assert.equals(0, options.getReverseHeartbeatInterval());

    Assert.raises(() -> options.setReverseHeartbeatInterval(-1), IllegalArgumentException);
  }

  function testSessionRecoveryTimeout() {
    Assert.equals(15000, options.getSessionRecoveryTimeout());

    options.setSessionRecoveryTimeout(1000);
    Assert.equals(1000, options.getSessionRecoveryTimeout());
    options.setSessionRecoveryTimeout(0);
    Assert.equals(0, options.getSessionRecoveryTimeout());

    Assert.raises(() -> options.setSessionRecoveryTimeout(-1), IllegalArgumentException);
  }

  function testStalledTimeout() {
    Assert.equals(2000, options.getStalledTimeout());

    options.setStalledTimeout(1000);
    Assert.equals(1000, options.getStalledTimeout());

    Assert.raises(() -> options.setStalledTimeout(0), IllegalArgumentException);
    Assert.raises(() -> options.setStalledTimeout(-1), IllegalArgumentException);
  }

  function testHttpExtraHeadersOnSessionCreationOnly() {
    Assert.equals(false, options.isHttpExtraHeadersOnSessionCreationOnly());

    options.setHttpExtraHeadersOnSessionCreationOnly(true);
    Assert.equals(true, options.isHttpExtraHeadersOnSessionCreationOnly());
  }

  function testServerInstanceAddressIgnored() {
    Assert.equals(false, options.isServerInstanceAddressIgnored());

    options.setServerInstanceAddressIgnored(true);
    Assert.equals(true, options.isServerInstanceAddressIgnored());
  }

  function testSlowingEnabled() {
    Assert.equals(false, options.isSlowingEnabled());

    options.setSlowingEnabled(true);
    Assert.equals(true, options.isSlowingEnabled());
  }
}