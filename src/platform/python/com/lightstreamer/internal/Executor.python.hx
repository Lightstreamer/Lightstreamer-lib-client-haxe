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

import python.lib.threading.Thread;

class Executor {
  final thread: Thread;
  final loop: Asyncio.EventLoop;

  public function new() {
    loop = Asyncio.new_event_loop();
    thread = new Thread({target: () -> {
      Asyncio.set_event_loop(loop);
      loop.run_forever();
      loop.close();
    },
    daemon: true
  });
    thread.start();
  }

  inline public function submit(callback: ()->Void): Void {
    loop.call_soon_threadsafe(callback);
  }

  inline public function schedule(callback: ()->Void, delay: Types.Millis): TaskHandle {
    return loop.call_later_threadsafe(delay / 1000.0, callback);
  }

  public function stop() {
    loop.call_soon_threadsafe(loop.stop);
    thread.join();
  }
}

abstract TaskHandle(Asyncio.Handle) from Asyncio.Handle {

  inline public function cancel(): Void {
    this.cancel();
  }

  inline public function isCanceled(): Bool {
    return this.cancelled();
  }
}