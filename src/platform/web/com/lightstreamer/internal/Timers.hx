package com.lightstreamer.internal;

typedef TimeoutHandle = Int;

inline function setTimeout(callback: ()->Void, delay: Int): TimeoutHandle {
  return js.Browser.window.setTimeout(callback, delay);
}

inline function clearTimeout(handle: TimeoutHandle) {
  js.Browser.window.clearTimeout(handle);
}

inline function setImmediate(callback: ()->Void): Void {
  js.Browser.window.setTimeout(callback);
}