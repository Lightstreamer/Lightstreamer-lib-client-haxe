package com.lightstreamer.internal;

import com.lightstreamer.internal.Threads;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

@:autoBuild(com.lightstreamer.internal.Macros.buildEventDispatcher())
class EventDispatcher<T> {
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
    userThread.submit(() -> {
      try {
        func(listener);
      } catch(e) {
        actionLogger.logErrorEx("Uncaught exception", e);
      }
    });
  }
}