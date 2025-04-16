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

import com.lightstreamer.internal.Timers;

class Executor {
  inline public function new() {}

  inline public function submit(cb: ()->Void): Void {
    setImmediate(cb);
  }

  inline public function schedule(callback: ()->Void, delay: Types.Millis): TaskHandle {
    return new TaskHandle(setTimeout(callback, delay));
  }

  inline public function stop(): Void {}
}

class TaskHandle {
  var handle: Null<TimeoutHandle>;

  inline public function new(handle: TimeoutHandle) {
    this.handle = handle;
  }

  inline public function isCanceled(): Bool {
    return handle == null;
  }

  public function cancel(): Void{
    if (handle != null) {
      clearTimeout(handle);
      handle = null;
    }
  }
}