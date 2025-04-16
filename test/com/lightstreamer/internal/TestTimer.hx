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