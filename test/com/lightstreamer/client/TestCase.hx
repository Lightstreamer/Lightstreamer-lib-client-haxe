package com.lightstreamer.client;

import utest.Assert;
import utest.Async;
import com.lightstreamer.log.ConsoleLoggerProvider;

class TestCase extends utest.Test {
  
  @Ignored
  function testLog() {
    var provider = new ConsoleLoggerProvider(ConsoleLogLevel.WARN);
    var log = provider.getLogger("foo");
    log.debug("log at debug");
    log.info("log at info");
    log.warn("log at warn");
    log.error("log at error");
    log.fatal("log at fatal");

    try {
      null.foo();
    } catch(e) {
      log.error("exception", e.native);
    }
    Assert.pass();
  }
}