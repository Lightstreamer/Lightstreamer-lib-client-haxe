package com.lightstreamer.internal.diff;

abstract Json(Dynamic) {
  public function toString(): String {
    return haxe.Json.stringify(this);
  }
}

typedef JsonPatch = Dynamic;