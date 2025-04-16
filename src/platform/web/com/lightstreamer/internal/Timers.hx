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

import com.lightstreamer.internal.WorkerTimer;
import com.lightstreamer.internal.Globals.instance as globals;

typedef TimeoutHandle = Int;

// fall-back to standard setTimeout in environments not supporting web workers (e.g. react native)
private final _setTimeout: (callback: ()->Void, delay: Int) -> TimeoutHandle = globals.hasWorkers ? WorkerTimer.setTimeout : js.Lib.global.setTimeout;
private final _clearTimeout: (handle: TimeoutHandle) -> Void = globals.hasWorkers ? WorkerTimer.clearTimeout : js.Lib.global.clearTimeout;
private final _setImmediate: (callback: ()->Void) -> Void = globals.hasMicroTasks ? js.Lib.global.queueMicrotask : (callback: ()->Void) -> {
  // ensure callbacks are called in the same order of _setImmediate invocations
  queue.push(callback);
  _setTimeout(handleQueue, 0);
};

inline function setTimeout(callback: ()->Void, delay: Int): TimeoutHandle {
  return _setTimeout(callback, delay);
}

inline function clearTimeout(handle: TimeoutHandle): Void {
  _clearTimeout(handle);
}

inline function setImmediate(callback: ()->Void): Void {
  _setImmediate(callback);
}

private final queue: Array<()->Void> = [];

private function handleQueue() {
  var task = queue.shift();
  if (task == null) {
    com.lightstreamer.log.LoggerTools.internalLogger.logError('Timer callback not found');
    return;
  }
  try {
    task();
  } catch(e) {
    com.lightstreamer.log.LoggerTools.internalLogger.logErrorEx('Timer callback failed', e);
  }
}