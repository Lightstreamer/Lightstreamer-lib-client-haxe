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