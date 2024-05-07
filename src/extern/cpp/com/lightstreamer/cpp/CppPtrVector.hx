package com.lightstreamer.cpp;

@:structAccess
@:include("vector")
@:native("std::vector<void*>")
extern class CppPtrVector extends CppVector<cpp.Void> {
  function new();
}