package com.lightstreamer.cpp;

import cpp.ConstCharStar;

@:forward
abstract CppConstStringRef(_CppConstStringRef) {
  @:to
  @:unreflective
  inline function to(): String {
    return this.c_str().toString();
  }
}

@:structAccess
@:include("string")
@:native("const std::string&")
private extern class _CppConstStringRef {
  function c_str(): ConstCharStar;
}