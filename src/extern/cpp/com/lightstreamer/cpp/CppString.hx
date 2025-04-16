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

import cpp.ConstCharStar;

@:forward
abstract CppString(_CppString) {
  @:from
  @:unreflective
  public static inline function of(s: String): CppString {
    return _CppString.of(s);
  }

  @:to
  @:unreflective
  inline function to(): String {
    return this.c_str().toString();
  }
}

@:structAccess
@:include("string")
@:native("std::string")
private extern class _CppString {
  function new();
  function c_str(): ConstCharStar;
  @:native("empty")
  function isEmpty(): Bool;
  
  static inline function of(s: String): CppString {
    return untyped __cpp__("std::string({0}.c_str())", s);
  }
}