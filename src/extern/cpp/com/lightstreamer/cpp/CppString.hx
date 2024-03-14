package com.lightstreamer.cpp;

import cpp.ConstCharStar;

abstract CppString(_CppString) {
  @:from
  @:unreflective
  static inline function of(s: String): CppString {
    return _CppString.of(s);
  }

  @:to
  @:unreflective
  function to(): String {
    return this.c_str().toString();
  }
}

@:structAccess
@:include("string")
@:native("std::string")
private extern class _CppString {
  function new();
  function c_str(): ConstCharStar;
  
  static inline function of(s: String): CppString {
    return untyped __cpp__("std::string({0}.c_str())", s);
  }
}