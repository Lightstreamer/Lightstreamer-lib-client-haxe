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