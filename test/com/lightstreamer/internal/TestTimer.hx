package com.lightstreamer.internal;

import com.lightstreamer.internal.Timer;

class TestTimer extends utest.Test {

  @:timeout(700)
  function testTimer(async: utest.Async) {
    var ts = haxe.Timer.stamp();
    var timer = new Timer("id", new Types.Millis(500), tr -> {
      var now = haxe.Timer.stamp();
      equals(false, tr.isCanceled());
      floatEquals(0.5, now - ts, 0.1);
      async.completed();
    });
  }

  @:timeout(700)
  function testCancel(async: utest.Async) {
    var timer = new Timer("id", new Types.Millis(100), tr -> {
      fail("Not expected");
      async.completed();
    });
    timer.cancel();
    delay(() -> {
      equals(true, timer.isCanceled());
      async.completed();
    }, 200);
  }

  function testDiff() {
    var diff: TimerMillis = new TimerStamp(2) - new TimerStamp(1);
    equals(1000, diff);
  }
}