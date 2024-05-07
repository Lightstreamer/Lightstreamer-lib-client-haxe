package com.lightstreamer.cpp;

@:structAccess
@:include("vector")
@:include("string")
@:native("std::vector<std::string>")
extern class CppStringVector extends CppVector<CppString> {
  function new();
  inline function toHaxe(): Array<String> {
    var res = new Array<String>();
    for (i in 0...this.size()) {
      var s: String = this.at(i);
      res.push(s);
    }
    return res;
  }
}