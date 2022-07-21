package jsonpatch;

import com.lightstreamer.internal.diff.Json;

@:jsRequire("jsonpatch")
extern class JsonPatcher {
  static function apply_patch(doc: Json, patch: JsonPatch): Json;
}