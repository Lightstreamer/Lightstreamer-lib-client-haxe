package com.lightstreamer.client;

import com.lightstreamer.client.NativeTypes.IllegalArgumentException;

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