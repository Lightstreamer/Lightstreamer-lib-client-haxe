package com.lightstreamer.internal.patch;

abstract Json(Dynamic) {
  public function new(str: String) {
    this = python.lib.Json.loads(str);
  }

  public function apply(patch: JsonPatch): Json {
    return JsonPatcher.apply_patch(this, patch);
  }

  public function toString(): String {
    // NB python_lib_Json was imported by `python.lib.Json.loads` in ctor
    return python.Syntax.code("python_lib_Json.dumps({0}, separators=(',', ':'))", this);
  }
}

typedef JsonPatch = Json;