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