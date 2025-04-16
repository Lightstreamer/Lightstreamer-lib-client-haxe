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
package com.lightstreamer.internal;

import haxe.macro.Expr;
using haxe.macro.Tools;

macro function assert(e: Expr) {
  var expr = e.toString();
  var pos = e.pos;
  return macro if (!$e) @:pos(pos) throw new com.lightstreamer.internal.NativeTypes.IllegalStateException("Assertion failure: " + $v{expr});
}

macro function goto(e) {
  var ee = [e, macro state.traceState()];
  return macro @:nullSafety(Off) @:privateAccess $b{ee}
}

macro function getDefine(key: String, defaultVal: String) {
  var val = haxe.macro.Context.definedValue(key);
  return macro $v{val ?? defaultVal};
}