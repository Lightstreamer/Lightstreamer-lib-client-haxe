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