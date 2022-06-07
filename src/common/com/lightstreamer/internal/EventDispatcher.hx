package com.lightstreamer.internal;

import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

@:autoBuild(com.lightstreamer.internal.Macros.buildEventDispatcher())
class EventDispatcher<T> {
  #if python
  // TODO remove python workaround
  // workaround for https://github.com/HaxeFoundation/haxe/issues/10562
  static function createExecutor() {
    haxe.Log.trace = (v, ?infos) -> {
      @:nullSafety(Off) var out = haxe.Log.formatOutput(v, infos);
      Sys.println(out);
    };
    return hx.concurrent.executor.Executor.create(1);
  }
  static final executor = createExecutor();
  #else
  static final executor = hx.concurrent.executor.Executor.create(1);
  #end
  var listeners = new Array<T>();

  public function new() {}

  public function addListener(listener: T): Bool {
    if (!listeners.contains(listener)) {
      listeners.push(listener);
      return true;
    }
    return false;
  }

  public function removeListener(listener: T): Bool {
    return listeners.remove(listener);
  }

  public function getListeners(): Array<T> {
    return listeners;
  }

  function dispatchToAll(func: T->Void) {
    for (l in listeners) {
      dispatchToOne(l, func);
    }
  }

  function dispatchToOne(listener: T, func: T->Void) {
    executor.submit(() -> {
      try {
        func(listener);
      } catch(e) {
        actionLogger.logErrorEx("Uncaught exception", e);
      }
    });
  }
}