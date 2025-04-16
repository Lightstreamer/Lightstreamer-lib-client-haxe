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

import com.lightstreamer.internal.NativeTypes.NativeArray;

@:forward
abstract CppStringVector(_CppStringVector) from _CppStringVector {
  @:unreflective
  inline public function new() {
    this = new _CppStringVector();
  }

  @:from
  @:unreflective
  public static function of(xs: NativeArray<String>): CppStringVector {
    var res = new _CppStringVector();
    for (s in xs) {
      res.push(s);
    }
    return res;
  }

  @:to
  @:unreflective
  public function toHaxe(): NativeArray<String> {
    var res = new Array<String>();
    for (i in 0...this.size()) {
      var s: String = this.at(i);
      res.push(s);
    }
    return res;
  }
}

@:structAccess
@:include("vector")
@:include("string")
@:native("std::vector<std::string>")
private extern class _CppStringVector extends CppVector<CppString> {
  function new();
}