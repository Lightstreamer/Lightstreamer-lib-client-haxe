package com.lightstreamer.internal;

import hx.concurrent.executor.Executor.TaskFuture;
import hx.concurrent.executor.Executor as HxExecutor;

class Executor {
  final exec: HxExecutor;

  inline public function new() {
    this.exec = HxExecutor.create(1);
  }

  inline public function submit(callback: ()->Void): Void {
    exec.submit(callback);
  }

  public function schedule(callback: ()->Void, delay: Types.Millis): TaskHandle {
    return exec.submit(callback, Schedule.ONCE(delay.toInt()));
  }

  public function stop() {
    exec.stop();
  }
}

abstract TaskHandle(TaskFuture<Void>) from TaskFuture<Void> {

  inline public function cancel(): Void {
    this.cancel();
  }

  inline public function isCanceled(): Bool {
    return this.isStopped;
  }
}