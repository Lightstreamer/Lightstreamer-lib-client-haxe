package com.lightstreamer.internal;

typedef TimeoutHandle = js.node.Timers.Timeout;

inline function setTimeout(callback: ()->Void, delay: Int): TimeoutHandle {
  return js.Node.setTimeout(callback, delay);
}

inline function clearTimeout(handle: TimeoutHandle) {
  js.Node.clearTimeout(handle);
}

inline function setImmediate(callback: ()->Void): Void {
  js.Node.setImmediate(callback);
}