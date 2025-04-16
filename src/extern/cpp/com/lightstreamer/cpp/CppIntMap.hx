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
package com.lightstreamer.cpp;

import com.lightstreamer.internal.NativeTypes.NativeIntMap;

@:forward
@:forward.new
abstract CppIntMap(_CppIntMap) from _CppIntMap {
  @:from
  @:unreflective
  static function of(m: NativeIntMap<Null<String>>): CppIntMap {
    var res = new _CppIntMap();
    for (k => v in m) {
      var vv = v ?? "";
      res.add(k, vv);
    }
    return res;
  }
}

@:structAccess
@:include("map")
@:native("std::map<int, std::string>")
private extern class _CppIntMap {
  function new();
  inline function add(key: Int, val: String): Void {
    var _key: Int = key;
    var _val: CppString = val;
    untyped __cpp__("{0}.insert(std::map<int, std::string>::value_type({1}, {2}))", this, _key, _val);
  }
}