package com.lightstreamer.internal;

import com.lightstreamer.internal.Executor;

class TestExecutor extends utest.Test {

  function testSubmit(async: utest.Async) {
    for (i in 0...100) {
      exps.await('$i');
    }
    exps
    .then(() -> async.completed())
    .verify();

    var exec = new Executor();
    for (i in 0...100) {
      exec.submit(() -> exps.signal('$i'));
    }
  }
}