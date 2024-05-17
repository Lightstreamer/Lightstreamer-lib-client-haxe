package com.lightstreamer.cpp;

import com.lightstreamer.internal.NativeTypes.NativeStringMap;

@:forward
@:forward.new
abstract CppStringMap(_CppStringMap) from _CppStringMap {
  @:from
  @:unreflective
  static function of(m: NativeStringMap<Null<String>>): CppStringMap {
    var res = new _CppStringMap();
    for (k => v in m) {
      var vv = v ?? "";
      res.add(k, vv);
    }
    return res;
  }

  @:to
  @:unreflective
  function to(): NativeStringMap<String> {
    var res = new Map<String, String>();
    untyped __cpp__("auto it = {0}.begin()", this);
    while (untyped __cpp__("it != {0}.end()", this)) {
      var k: CppConstStringRef = untyped __cpp__("it->first");
      var v: CppConstStringRef = untyped __cpp__("it->second");
      res[k] = v;
      untyped __cpp__("it++");
    }
    return res;
  }
}

@:structAccess
@:include("map")
@:native("std::map<std::string, std::string>")
private extern class _CppStringMap {
  function new();
  inline function add(key: String, val: String): Void {
    var _key: CppString = key;
    var _val: CppString = val;
    untyped __cpp__("{0}.insert(std::map<std::string, std::string>::value_type({1}, {2}))", this, _key, _val);
  }
}