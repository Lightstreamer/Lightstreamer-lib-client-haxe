package com.lightstreamer.internal;

typedef TimeoutHandle = Int;

inline function setTimeout(callback: ()->Void, delay: Int): TimeoutHandle {
  return js.Lib.global.setTimeout(callback, delay);
}

inline function clearTimeout(handle: TimeoutHandle) {
  js.Lib.global.clearTimeout(handle);
}

inline function setImmediate(callback: ()->Void): Void {
  js.Lib.global.setTimeout(callback);
}