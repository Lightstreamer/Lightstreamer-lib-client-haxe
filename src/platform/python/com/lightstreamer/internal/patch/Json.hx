/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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