package com.lightstreamer.internal;

import com.lightstreamer.internal.Threads.sessionThread;
import com.lightstreamer.internal.PlatformApi;

class TimerImpl implements ITimer {
  final task: Asyncio.Handle;

  public function new(id: String, delay: Types.Millis, callback: ITimer->Void) {
    task = sessionThread.schedule(() -> callback(this), delay);
  }

  inline public function cancel(): Void {
    task.cancel();
  }

  inline public function isCanceled(): Bool {
    return task.cancelled();
  }

  inline static public function stamp(): Float {
    return haxe.Timer.stamp();
  }
}