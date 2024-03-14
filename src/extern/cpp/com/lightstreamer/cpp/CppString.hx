package com.lightstreamer.cpp;

abstract CppString(_CppString) {
  @:from
  @:unreflective
  static inline function of(s: String): CppString {
    return _CppString.of(s);
  }
}

@:include("string")
@:native("std::string")
private extern class _CppString {
  function new();
  
  static inline function of(s: String): CppString {
    return untyped __cpp__("std::string({0}.c_str())", s);
  }
}