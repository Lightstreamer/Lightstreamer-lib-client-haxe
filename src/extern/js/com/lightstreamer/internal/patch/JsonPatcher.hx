package com.lightstreamer.internal.patch;

import com.lightstreamer.internal.patch.Json;

@:jsRequire("jsonpatch")
extern class JsonPatcher {
  static function apply_patch(doc: Json, patch: JsonPatch): Json;
}