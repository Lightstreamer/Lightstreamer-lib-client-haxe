package com.lightstreamer.client;

import com.lightstreamer.client.Types.IllegalArgumentException;
import utest.Assert;

class ConnectionDetailsTest extends utest.Test {
  var client = new LightstreamerClient("http://example.com", "TEST");

  function testServerAddress() {
    Assert.equals("http://example.com", client.connectionDetails.getServerAddress());

    client.connectionDetails.setServerAddress("https://example.com:8080/ls");
    Assert.equals("https://example.com:8080/ls", client.connectionDetails.getServerAddress());

    Assert.raises(() -> client.connectionDetails.setServerAddress("example.com"), IllegalArgumentException);
    Assert.raises(() -> client.connectionDetails.setServerAddress("tcp://example.com"), IllegalArgumentException);
  }

  function testAdapterSet() {
    Assert.equals("TEST", client.connectionDetails.getAdapterSet());

    client.connectionDetails.setAdapterSet("DEMO");
    Assert.equals("DEMO", client.connectionDetails.getAdapterSet());
  }

  function testUser() {
    Assert.equals(null, client.connectionDetails.getUser());

    client.connectionDetails.setUser("user");
    Assert.equals("user", client.connectionDetails.getUser());
  }
}