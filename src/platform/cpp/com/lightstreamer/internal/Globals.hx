package com.lightstreamer.internal;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();
  function new() {}
  public function toString(): String return "{}";
}