package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi;

class TimerImpl implements ITimer {
  @:volatile
  var disposed = false;
  final task: cs.system.threading.Timer;

  public function new(id: String, delay: Types.Millis, callback: ITimer->Void) {
    this.task = new cs.system.threading.Timer(obj -> callback(cast obj), this, delay, -1);
  }

  public function cancel(): Void {
    if (!disposed) {
      disposed = true;
      task.Dispose();
    }
  }

  inline public function isCanceled(): Bool {
    return disposed;
  }
}