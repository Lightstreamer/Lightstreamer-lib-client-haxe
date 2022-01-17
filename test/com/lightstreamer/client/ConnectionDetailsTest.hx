package com.lightstreamer.client;

import com.lightstreamer.client.NativeTypes.IllegalArgumentException;
import utest.Assert;

class ConnectionDetailsTest extends utest.Test {
  var details = new LightstreamerClient("http://example.com", "TEST").connectionDetails;

  function testServerAddress() {
    Assert.equals("http://example.com", details.getServerAddress());

    details.setServerAddress("https://example.com:8080/ls");
    Assert.equals("https://example.com:8080/ls", details.getServerAddress());

    Assert.raises(() -> details.setServerAddress("example.com"), IllegalArgumentException);
    Assert.raises(() -> details.setServerAddress("tcp://example.com"), IllegalArgumentException);
  }

  function testAdapterSet() {
    Assert.equals("TEST", details.getAdapterSet());

    details.setAdapterSet("DEMO");
    Assert.equals("DEMO", details.getAdapterSet());
  }

  function testUser() {
    Assert.equals(null, details.getUser());

    details.setUser("user");
    Assert.equals("user", details.getUser());
  }
}