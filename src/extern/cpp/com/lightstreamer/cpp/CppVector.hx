package com.lightstreamer.cpp;

import cpp.Reference;
import cpp.SizeT;

@:structAccess
@:include("vector")
@:native("std::vector")
extern class CppVector<T> {
  function new();
  function size(): SizeT;
  @:native("empty")
  function isEmpty(): Bool;
  function push_back(val: Reference<T>): Void;
  function at(n: SizeT): Reference<T>;
  inline function push(val: Reference<T>): Void push_back(val);
}