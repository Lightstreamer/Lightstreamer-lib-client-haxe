package com.lightstreamer.client;

import utest.Assert;
import utest.Async;
import com.lightstreamer.log.ConsoleLoggerProvider;

class TestCase extends utest.Test {
  
  function testServerAddress() {
    var client = new LightstreamerClient("http://localhost", "TEST");
    Assert.equals("http://localhost", client.details.getServerAddress());
  }

  function testAdapterSet() {
    var client = new LightstreamerClient("http://localhost", "TEST");
    Assert.equals("TEST", client.details.getAdapterSet());
  }

  function testLog() {
    var provider = new ConsoleLoggerProvider(ConsoleLogLevel.WARN);
    var log = provider.getLogger("foo");
    log.debug("log at debug");
    log.info("log at info");
    log.warn("log at warn");
    log.error("log at error");
    log.fatal("log at fatal");

    #if js
    try {
      throw new js.lib.Error("Exception");
    } catch(e: js.lib.Error) {
      log.error("exception", e);
    }
    #elseif java
    try {
      throw new java.lang.RuntimeException("Exception");
    } catch(e: java.lang.Exception) {
      log.error("exception", e);
    }
    #elseif cs
    try {
      throw new cs.system.Exception("Exception");
    } catch(e: cs.system.Exception) {
      log.error("exception", e);
    }
    #end
    Assert.pass();
  }
}