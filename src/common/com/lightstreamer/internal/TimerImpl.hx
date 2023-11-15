package com.lightstreamer.internal;

import com.lightstreamer.internal.Threads;
import com.lightstreamer.internal.PlatformApi.ITimer;
import hx.concurrent.executor.Executor.TaskFuture;

class TimerImpl implements ITimer {
  final task: TaskFuture<Void>;

  public function new(id: String, delay: Types.Millis, callback: ITimer->Void) {
    task = sessionThread.schedule(() -> callback(this), delay);
  }

  inline public function cancel(): Void {
    task.cancel();
  }

  inline public function isCanceled(): Bool {
    return task.isStopped;
  }
}