package com.lightstreamer.internal;

import com.lightstreamer.internal.WorkerTimer;

typedef TimeoutHandle = Int;

// fall-back to standard setTimeout in environments not supporting web workers (e.g. react native)
private final hasWorkers = js.Lib.typeof(js.html.Worker) != "undefined";
private final _setTimeout: (callback: ()->Void, delay: Int) -> TimeoutHandle = hasWorkers ? WorkerTimer.setTimeout : cast js.Browser.window.setTimeout;
private final _clearTimeout: (handle: TimeoutHandle) -> Void = hasWorkers ? WorkerTimer.clearTimeout : js.Browser.window.clearTimeout;

inline function setTimeout(callback: ()->Void, delay: Int): TimeoutHandle {
  return _setTimeout(callback, delay);
}

inline function clearTimeout(handle: TimeoutHandle) {
  _clearTimeout(handle);
}

function setImmediate(callback: ()->Void): Void {
  queue.push(callback);
  _setTimeout(handleQueue, 0);
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