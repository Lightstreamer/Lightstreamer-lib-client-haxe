package com.lightstreamer.internal.patch;

import com.lightstreamer.cs.JsonHelper;

abstract Json(cs.system.Object) {
  public function new(str: String) {
    this = JsonHelper.ParseJson(str);
  }

  public function apply(patch: JsonPatch): Json {
    return JsonHelper.ApplyPatch(this, patch);
  }

  public function toString(): String {
    return JsonHelper.Stringify(this);
  }
}

abstract JsonPatch(cs.system.Object) {
  public function new(str: String) {
    this = JsonHelper.ParseJsonPatch(str);
  }

  public function toString(): String {
    return JsonHelper.Stringify(this);
  }
}
