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