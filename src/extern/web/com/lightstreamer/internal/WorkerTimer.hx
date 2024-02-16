package com.lightstreamer.internal;

@:jsRequire("./worker-timers.js")
extern class WorkerTimer {
  static function setTimeout(func: ()->Void, delay: Int): Int;
  static function clearTimeout(id: Int): Void;
}