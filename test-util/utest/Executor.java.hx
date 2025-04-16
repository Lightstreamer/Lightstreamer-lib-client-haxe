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
package utest;

import java.util.concurrent.Callable;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.ScheduledFuture;
import java.lang.Runnable;

class Executor {
  final exec: ScheduledExecutorService;

  inline public function new() {
    this.exec = Executors.newSingleThreadScheduledExecutor();
  }

  public function schedule(callback: ()->Void, delay: Int): TaskHandle {
    // workaround for issue https://github.com/HaxeFoundation/haxe/issues/11236
    if (callback is Runnable) {
      return exec.schedule((cast callback: Runnable), delay, TimeUnit.MILLISECONDS);
    } else {
      return exec.schedule((cast callback: Callable<Dynamic>), delay, TimeUnit.MILLISECONDS);
    }
  }
}

abstract TaskHandle(ScheduledFuture) from ScheduledFuture {

  inline public function cancel(): Void {
    this.cancel(false);
  }
}