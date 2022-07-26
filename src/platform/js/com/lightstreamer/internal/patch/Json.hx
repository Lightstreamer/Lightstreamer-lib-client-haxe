package com.lightstreamer.internal.patch;

import com.lightstreamer.internal.patch.JsonPatcher;

abstract Json(Dynamic) {
  public function new(str: String) {
    this = haxe.Json.parse(str);
  }

  public function apply(patch: JsonPatch): Json {
    return JsonPatcher.apply_patch(this, patch);
  }

  public function toString(): String {
    return haxe.Json.stringify(this);
  }
}

typedef JsonPatch = Json;