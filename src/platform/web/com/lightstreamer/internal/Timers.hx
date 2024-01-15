package com.lightstreamer.internal;

import com.lightstreamer.internal.WorkerTimer;

typedef TimeoutHandle = Int;

inline function setTimeout(callback: ()->Void, delay: Int): TimeoutHandle {
  return WorkerTimer.setTimeout(callback, delay);
}

inline function clearTimeout(handle: TimeoutHandle) {
  WorkerTimer.clearTimeout(handle);
}

function setImmediate(callback: ()->Void): Void {
  queue.push(callback);
  WorkerTimer.setTimeout(handleQueue, 0);
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