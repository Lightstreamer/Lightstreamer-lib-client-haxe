package com.lightstreamer.internal;

import haxe.macro.Expr;
using haxe.macro.Tools;

macro function assert(e: Expr) {
  var expr = e.toString();
  var pos = e.pos;
  return macro if (!$e) @:pos(pos) throw new haxe.Exception("Assertion failure: " + $v{expr});
}

macro function bypassAccessors(e) 
  return _bypassAccessors(e);

private function _bypassAccessors(e: Expr) {
  return switch e.expr {
    case EBinop(OpAssign, _, _):
      {expr: EMeta({pos: e.pos, name: ":bypassAccessor"}, e), pos: e.pos};
    case _:
      e.map(_bypassAccessors);
  }
}