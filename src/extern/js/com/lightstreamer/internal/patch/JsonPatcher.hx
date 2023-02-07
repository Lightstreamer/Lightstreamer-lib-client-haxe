package com.lightstreamer.internal.patch;

#if LS_JSON_PATCH
import com.lightstreamer.internal.patch.Json;

@:jsRequire("jsonpatch")
extern class JsonPatcher {
  static function apply_patch(doc: Json, patch: JsonPatch): Json;
}
#end