package com.lightstreamer.client;

import utest.Assert;
import utest.Async;

class TestCase extends utest.Test {
  
  function testServerAddress() {
    var client = new LightstreamerClient("http://localhost", "TEST");
    Assert.equals("http://localhost", client.details.getServerAddress());
  }

  function testAdapterSet() {
    var client = new LightstreamerClient("http://localhost", "TEST");
    Assert.equals("TEST", client.details.getAdapterSet());
  }
}