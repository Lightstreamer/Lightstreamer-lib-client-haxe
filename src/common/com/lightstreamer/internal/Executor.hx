package com.lightstreamer.internal;

abstract Executor(hx.concurrent.executor.Executor) {
  inline public function new() {
    this = hx.concurrent.executor.Executor.create();
  }

  inline public function submit(callback: ()->Void) {
    this.submit(callback);
  }

  inline public function schedule(callback: ()->Void, delay: Types.Millis) {
    return this.submit(callback, Schedule.ONCE(delay.toInt()));
  }

  public function stop() {
    this.stop();
    #if threads
    hx.concurrent.thread.Threads.await(() -> this.state == hx.concurrent.Service.ServiceState.STOPPED, -1);
    #end
  }
}