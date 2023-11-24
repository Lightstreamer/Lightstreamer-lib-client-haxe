package com.lightstreamer.internal;

import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.ScheduledFuture;
import java.lang.Runnable;

class Executor {
  final exec: ScheduledExecutorService;

  inline public function new() {
    this.exec = Executors.newSingleThreadScheduledExecutor();
  }

  inline public function submit(callback: ()->Void): Void {
    exec.execute((cast callback: Runnable));
  }

  inline public function schedule(callback: ()->Void, delay: Types.Millis): TaskHandle {
    return exec.schedule((cast callback: Runnable), delay, TimeUnit.MILLISECONDS);
  }

  public function stop() {
    exec.shutdown();
    exec.awaitTermination(java.lang.Long.MAX_VALUE, TimeUnit.MILLISECONDS);
  }
}

abstract TaskHandle(ScheduledFuture) from ScheduledFuture {

  inline public function cancel(): Void {
    this.cancel(false);
  }

  inline public function isCanceled(): Bool {
    return this.isCancelled();
  }
}