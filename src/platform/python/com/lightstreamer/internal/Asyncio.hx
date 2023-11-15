package com.lightstreamer.internal;

import haxe.extern.EitherType;

@:pythonImport("asyncio")
extern class Asyncio {
  static function new_event_loop(): EventLoop;
  static function set_event_loop(loop: EventLoop): Void;
}

extern class EventLoop {
  function run_forever(): Void;
  function stop(): Void;
  function close(): Void;
  function call_soon(cb: ()->Void, ...args: Dynamic): Handle;
  function call_later(delay: EitherType<Int, Float>, cb: ()->Void, ...args: Dynamic): TimerHandle;
  function call_soon_threadsafe(cb: ()->Void, ...args: Dynamic): Handle;

  inline function call_later_threadsafe(delay: EitherType<Int, Float>, cb: ()->Void/*, ...args: Dynamic*/): Handle {
    return call_soon_threadsafe(cast call_later, delay, cb);
  }
}

extern class Handle {
  function cancel(): Void;
  function cancelled(): Bool;
}

extern class TimerHandle extends Handle {
  function when(): Float;
}