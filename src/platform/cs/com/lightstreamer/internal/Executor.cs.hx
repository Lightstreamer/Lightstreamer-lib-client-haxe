package com.lightstreamer.internal;

abstract Executor(CustomThreadPool) {
  inline public function new() {
    this = new CustomThreadPool(1);
  }

  inline public function submit(callback: ()->Void): Void {
    this.QueueUserWorkItem(_ -> callback(), null);
  }

  inline public function stop(): Void {
    this.Dispose();
  }
}