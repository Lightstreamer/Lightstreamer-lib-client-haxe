package com.lightstreamer.internal;

import com.lightstreamer.internal.Threads;
import com.lightstreamer.internal.PlatformApi.ITimer;
import com.lightstreamer.internal.Executor.TaskHandle;

class TimerImpl implements ITimer {
  final task: TaskHandle;

  public function new(id: String, delay: Types.Millis, callback: ITimer->Void) {
    task = sessionThread.schedule(() -> callback(this), delay);
  }

  inline public function cancel(): Void {
    task.cancel();
  }

  inline public function isCanceled(): Bool {
    return task.isCanceled();
  }
}