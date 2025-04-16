/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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