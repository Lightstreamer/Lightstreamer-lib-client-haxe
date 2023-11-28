package com.lightstreamer.internal;

class RLock {
  #if target.threaded
  final lock = new sys.thread.Mutex();
  #end

  inline public function new() {}

  inline public function acquire() {
    #if target.threaded
    lock.acquire();
    #end
  }

  inline public function release() {
    #if target.threaded
    lock.release();
    #end
  }

  public function synchronized<T>(func: ()->T): T {
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