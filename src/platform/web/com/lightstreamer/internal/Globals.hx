package com.lightstreamer.internal;

class Globals {
  static public final instance = new Globals();

  public final hasWorkers = js.Lib.typeof(js.html.Worker) != "undefined";
  public final hasMicroTasks = js.Lib.typeof(js.Lib.global.queueMicrotask) != "undefined";

  function new() {}

  public function toString() {
    return '{ hasWorkers: $hasWorkers, hasMicroTasks: $hasMicroTasks }';
  }
}