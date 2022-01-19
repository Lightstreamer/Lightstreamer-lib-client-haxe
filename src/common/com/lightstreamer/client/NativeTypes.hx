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
#elseif cpp
typedef ExceptionImpl = Any
#end

abstract Exception(ExceptionImpl) {

  @:access(haxe.Exception.caught)
  inline public function details() {
    return haxe.Exception.caught(this).details();
  }
}

#if java
typedef IllegalArgumentException = java.lang.IllegalArgumentException
typedef IllegalStateException = java.lang.IllegalStateException
#elseif cs
typedef IllegalArgumentException = cs.system.ArgumentException
typedef IllegalStateException = cs.system.InvalidOperationException
#else
class IllegalArgumentException extends haxe.Exception {}
class IllegalStateException extends haxe.Exception {}
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

  public function toString() {
    var out = new StringBuf();
    var it = this.GetEnumerator();
    out.add("{\n");
    while (it.MoveNext()) {
      var entry = it.Current;
      out.add(entry.Key + "=" + entry.Value + "\n");
    }
    out.add("}");
    return out.toString();
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

#if js
abstract NativeList<T>(Array<T>) {
  public inline function new(lst: Array<T>) {
    this = lst.copy();
  }

  public inline function toHaxe() {
    return this.copy();
  }
}
#elseif java
abstract NativeList<T>(java.util.List<T>) {
  public function new(lst: Array<T>) {
    var out = new java.util.ArrayList<T>();
    for (e in lst) {
      out.add(e);
    }
    this = out;
  }

  public function toHaxe() {
    return [for (e in this) e];
  }
}
#elseif cs
abstract NativeList<T>(cs.system.collections.generic.IList_1<T>) {
  // TODO remove inline (see issue https://github.com/HaxeFoundation/haxe/issues/10556)
  public inline function new(lst: Array<T>) {
    var out = new cs.system.collections.generic.List_1<T>();
    for (e in lst) {
      out.Add(e);
    }
    this = out;
  }

  public function toHaxe(): Array<T> {
    var out = [];
    var it = this.GetEnumerator();
    while (it.MoveNext()) {
      out.push(it.Current);
    }
    return out;
  }
}
#elseif python
abstract NativeList<T>(Array<T>) {
  public inline function new(lst: Array<T>) {
    this = lst.copy();
  }

  public inline function toHaxe(): Array<T> {
    return this.copy();
  } 
}
#elseif php
abstract NativeList<T>(php.NativeIndexedArray<T>) {
  public function new(lst: Array<T>) {
    var out = new php.NativeIndexedArray<T>();
    for (e in lst) {
      out.push(e);
    }
    this = out;
  }

  public function toHaxe(): Array<T> {
    return [for (e in this) e];
  }
}
#end

#if js
abstract NativeArray<T>(Array<T>) {
  public inline function new(a: Array<T>) {
    this = a.copy();
  }

  public inline function toHaxe(): Array<T> {
    return this.copy();
  }
}
#elseif java
abstract NativeArray<T>(java.NativeArray<T>) {
  public inline function new(a: Array<T>) {
    this = java.Lib.nativeArray(a, true);
  }

  public inline function toHaxe(): Array<T> {
    return java.Lib.array(this);
  }
}
#elseif cs
abstract NativeArray<T>(cs.NativeArray<T>) {
  public inline function new(a: Array<T>) {
    this = cs.Lib.nativeArray(a, true);
  }

  public inline function toHaxe(): Array<T> {
    return cs.Lib.array(this);
  }
}
#elseif python
abstract NativeArray<T>(Array<T>) {
  public inline function new(a: Array<T>) {
    this = a.copy();
  }

  public inline function toHaxe(): Array<T> {
    return this.copy();
  }
}
#elseif php
abstract NativeArray<T>(php.NativeArray) {
  public inline function new(a: Array<T>) {
    this = php.Lib.toPhpArray(a);
  }

  public inline function toHaxe(): Array<T> {
    return php.Lib.toHaxeArray(this);
  }
}
#end