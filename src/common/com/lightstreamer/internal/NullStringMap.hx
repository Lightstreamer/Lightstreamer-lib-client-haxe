package com.lightstreamer.internal;

import haxe.ds.StringMap;

@:forward(toString)
abstract NullStringMap(StringMap<String>) {
  public function new() {
    this = new StringMap();
  }

  @:op([])
  public function set(k: String, v: Null<Any>) {
    if (v != null) {
      this.set(k, Std.string(v));
    }
  }
}