package com.lightstreamer.internal;

abstract RLock(hx.concurrent.lock.RLock) {
  inline public function new() {
    this = new hx.concurrent.lock.RLock();
  }

  public function execute<T>(func: ()->T): T {
    var ex: Null<haxe.Exception> = null;
    var result: Null<T> = null;

    this.acquire();
    try {
       result = func();
    } catch (e) {
       ex = e;
    }
    this.release();

    if (ex != null)
       throw ex;
    @:nullSafety(Off)
    return result;
  }
}