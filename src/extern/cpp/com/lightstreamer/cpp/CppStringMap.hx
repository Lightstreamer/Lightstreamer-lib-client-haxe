package com.lightstreamer.cpp;

@:include("unordered_map")
@:native("std::unordered_map<std::string, std::string>")
extern class CppStringMap {
  function new();
  inline function add(key: String, val: String): Void {
    var _key = CppString.of(key);
    var _val = CppString.of(val);
    untyped __cpp__("{0}.insert(std::map<std::string, std::string>::value_type({1}, {2}))", this, _key, _val);
  }
}