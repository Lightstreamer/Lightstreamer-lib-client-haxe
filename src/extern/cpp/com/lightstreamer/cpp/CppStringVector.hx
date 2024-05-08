package com.lightstreamer.cpp;

@:structAccess
@:include("vector")
@:include("string")
@:native("std::vector<std::string>")
extern class CppStringVector extends CppVector<CppString> {
  function new();
  inline function toHaxe(): Array<String> {
    return _toHaxe(this);
  }
}

@:unreflective
@:nullSafety(Off)
private function _toHaxe(source: cpp.ConstStar<CppVector<CppString>>): Array<String> {
  var res = new Array<String>();
  for (i in 0...source.size()) {
    var s: String = source.at(i);
    res.push(s);
  }
  return res;
}