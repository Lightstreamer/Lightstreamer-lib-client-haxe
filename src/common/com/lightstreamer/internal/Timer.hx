package com.lightstreamer.internal;

import hx.concurrent.executor.Executor;
import com.lightstreamer.internal.PlatformApi;

class Timer implements ITimer {
  static final executor = Executor.create();
  final task: TaskFuture<Void>;

  public function new(id: String, delay: Types.Millis, callback: ITimer->Void) {
    task = executor.submit(() -> callback(this), Schedule.ONCE(delay.toInt()));
  }

  inline public function cancel(): Void {
    task.cancel();
  }

  inline public function isCanceled(): Bool {
    return task.isStopped;
  }

  inline static public function stamp(): Float {
    return haxe.Timer.stamp();
  }
}