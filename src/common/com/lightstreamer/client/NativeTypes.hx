package com.lightstreamer.client;

typedef Long = #if (java || cs) haxe.Int64 #else Int #end

#if js
typedef ExceptionImpl = js.lib.Error
#elseif java
typedef ExceptionImpl = java.lang.Throwable
#elseif cs
typedef ExceptionImpl = cs.system.Exception
#elseif python
typedef ExceptionImpl = python.Exceptions.BaseException
#elseif php
typedef ExceptionImpl = php.Throwable
#end

abstract Exception(ExceptionImpl) {

  @:access(haxe.Exception.caught)
  inline public function details() {
    return haxe.Exception.caught(this).details();
  }
}

#if java
typedef IllegalArgumentException = java.lang.IllegalArgumentException
#elseif cs
typedef IllegalArgumentException = cs.system.ArgumentException
#else
class IllegalArgumentException extends haxe.Exception {}
#end

#if js
abstract NativeStringMap(js.lib.Object) {
  @:from
  public static inline function fromHaxeMap(map) {
    return new NativeStringMap(map);
  }

  @:to
  public inline function toHaxeMap() {
    return toHaxe();
  }

  public function new(map: Map<String, String>) {
    var out: haxe.DynamicAccess<String> = {};
    for (k => v in map) {
      out[k] = v;
    }
    this = cast out;
  }

  public function toHaxe(): Map<String, String> {
    var out = new Map<String, String>();
    for (entry in js.lib.Object.entries(this)) {
      out[entry.key] = entry.value;
    }
    return out;
  }
}
#elseif java
abstract NativeStringMap(java.util.Map<String, String>) {
  @:from
  public static inline function fromHaxeMap(map) {
    return new NativeStringMap(map);
  }

  @:to
  public inline function toHaxeMap() {
    return toHaxe();
  }

  public function new(map: Map<String, String>) {
    var out = new java.util.HashMap<String, String>();
    for (k => v in map) {
      out.put(k, v);
    }
    this = out;
  }

  public function toHaxe(): Map<String, String> {
    var out = new Map<String, String>();
    for (entry in this.entrySet()) {
      out[entry.getKey()] = entry.getValue();
    }
    return out;
  }
}
#elseif cs
abstract NativeStringMap(cs.system.collections.generic.IDictionary_2<String, String>) {
  @:from
  public static inline function fromHaxeMap(map) {
    return new NativeStringMap(map);
  }

  @:to
  public inline function toHaxeMap() {
    return toHaxe();
  }

  public function new(map: Map<String, String>) {
    var out = new cs.system.collections.generic.Dictionary_2<String, String>();
    for (k => v in map) {
      out.Add(k, v);
    }
    this = out;
  }

  public function toHaxe(): Map<String, String> {
    var out = new Map<String, String>();
    var it = this.GetEnumerator();
    while (it.MoveNext()) {
      var entry = it.Current;
      out[entry.Key] = entry.Value;
    }
    return out;
  }
}
#elseif python
abstract NativeStringMap(python.Dict<String, String>) {
  @:from
  public static inline function fromHaxeMap(map) {
    return new NativeStringMap(map);
  }

  @:to
  public inline function toHaxeMap() {
    return toHaxe();
  }

  public function new(map: Map<String, String>) {
    var out = new python.Dict<String, String>();
    for (k => v in map) {
      out.set(k, v);
    }
    this = out;
  }

  public function toHaxe(): Map<String, String> {
    var out = new Map<String, String>();
    for (entry in this.items()) {
      out[entry._1] = entry._2;
    }
    return out;
  }
}
#elseif php
abstract NativeStringMap(php.NativeAssocArray<String>) {
  @:from
  public static inline function fromHaxeMap(map) {
    return new NativeStringMap(map);
  }

  @:to
  public inline function toHaxeMap() {
    return toHaxe();
  }

  public function new(map: Map<String, String>) {
    var out = new php.NativeAssocArray<String>();
    for (k => v in map) {
      out[k] = v;
    }
    this = out;
  }

  public function toHaxe(): Map<String, String> {
    var out = new Map<String, String>();
    for (k => v in this) {
      out[k] = v;
    }
    return out;
  }
}
#end