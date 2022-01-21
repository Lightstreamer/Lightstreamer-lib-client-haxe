package com.lightstreamer.client;

@:autoBuild(com.lightstreamer.client.Macros.buildEventDispatcher())
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
    // TODO dispatch event to event loop
    func(listener);
  }
}