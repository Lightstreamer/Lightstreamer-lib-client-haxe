package com.lightstreamer.internal;

#if java
typedef Long = java.StdTypes.Int64;
#elseif cs
typedef Long = cs.StdTypes.Int64;
#else
typedef Long = Int;
#end

#if js
typedef NativeExceptionImpl = js.lib.Error
#elseif java
typedef NativeExceptionImpl = java.lang.Throwable
#elseif cs
typedef NativeExceptionImpl = cs.system.Exception
#elseif python
typedef NativeExceptionImpl = python.Exceptions.BaseException
#elseif php
typedef NativeExceptionImpl = php.Throwable
#elseif cpp
typedef NativeExceptionImpl = Any
#end

abstract NativeException(NativeExceptionImpl) from NativeExceptionImpl {

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
abstract NativeStringMap<V>(haxe.DynamicAccess<V>) {
  @:from
  static inline function fromHaxeMap<V>(map: Map<String, V>) {
    return new NativeStringMap(map);
  }

  @:to
  inline function toHaxeMap() {
    return toHaxe();
  }

  public overload inline extern function new(map: Map<String, V>) {
    this = fromMapToDynamicAccess(map);
  }
  
  public overload inline extern function new(map: haxe.DynamicAccess<V>) {
    this = map.copy();
  }

  static function fromMapToDynamicAccess<V>(map: Map<String, V>) {
    var out: haxe.DynamicAccess<V> = {};
    for (k => v in map) {
      out[k] = v;
    }
    return out;
  }

  public function toHaxe(): Map<String, V> {
    var out = new Map<String, V>();
    @:nullSafety(Off) 
    for (k => v in this) {
      out[k] = v;
    }
    return out;
  }

  public function toDynamicAccess(): haxe.DynamicAccess<V> {
    @:nullSafety(Off) return this.copy();
  }
}
#if LS_TEST
abstract NativeIntMap<V>(haxe.DynamicAccess<V>) {
  public function new(map: Map<Int, V>) {
    var out: haxe.DynamicAccess<V> = {};
    for (k => v in map) {
      out[Std.string(k)] = v;
    }
    this = out;
  }

  @:from
  static inline function fromHaxeMap<V>(map: Map<Int, V>) {
    return new NativeIntMap(map);
  }

  @:to
  function toHaxe(): Map<Int, V> {
    var out = new Map<Int, V>();
    @:nullSafety(Off) 
    for (k => v in this) {
      out[Std.parseInt(k)] = v;
    }
    return out;
  }
}
#end
#elseif java
function toNativeMap<K, V>(map: Map<K, V>, out: java.util.Map<K, V>) {
  for (k => v in map) {
    out.put(k, v);
  }
  return out;
}

function toMap<K, V>(map: java.util.Map<K, V>, out: Map<K, V>) {
  for (entry in map.entrySet()) {
    out[entry.getKey()] = entry.getValue();
  }
  return out;
}

abstract NativeStringMap<V>(java.util.Map<String, V>) {
  public overload function new(map: Map<String, V>) {
    var out = new java.util.HashMap<String, V>();
    this = toNativeMap(map, out);
  }

  public overload function new(map: haxe.DynamicAccess<V>) {
    var out = new java.util.HashMap<String, V>();
    for (k => v in map) {
      out.put(k, v);
    }
    this = out;
  }

  @:from
  static function fromHaxe(map) {
    return new NativeStringMap(map);
  }

  @:to
  public function toHaxe(): Map<String, V> {
    var out = new Map<String, V>();
    return toMap(this, out);
  }

  public function toDynamicAccess(): haxe.DynamicAccess<V> {
    var out = new haxe.DynamicAccess<V>();
    for (entry in this.entrySet()) {
      out[entry.getKey()] = entry.getValue();
    }
    return out;
  }
}

abstract NativeIntMap<V>(java.util.Map<Int, V>) {
  public function new(map: Map<Int, V>) {
    var out = new java.util.HashMap<Int, V>();
    this = toNativeMap(map, out);
  }

  @:to
  function toHaxe(): Map<Int, V> {
    var out = new Map<Int, V>();
    return toMap(this, out);
  }
}
#elseif cs
function toNativeMap<K, V>(map: Map<K, V>, out: cs.system.collections.generic.IDictionary_2<K, V>) {
  for (k => v in map) {
    out.Add(k, v);
  }
  return out;
}

function toMap<K, V>(map: cs.system.collections.generic.IDictionary_2<K, V>, out: Map<K, V>) {
  var it = map.GetEnumerator();
  while (it.MoveNext()) {
    var entry = it.Current;
    out[entry.Key] = entry.Value;
  }
  return out;
}

abstract NativeStringMap<V>(cs.system.collections.generic.IDictionary_2<String, V>) to cs.system.collections.generic.IDictionary_2<String, V> {
  public function new(map: Map<String, V>) {
    var out = new cs.system.collections.generic.Dictionary_2<String, V>();
    this = toNativeMap(map, out);
  }

  @:from
  static function fromHaxe(map) {
    return new NativeStringMap(map);
  }

  @:to
  public function toHaxe(): Map<String, V> {
    var out = new Map<String, V>();
    return toMap(this, out);
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

abstract NativeIntMap<V>(cs.system.collections.generic.IDictionary_2<Int, V>) {
  public function new(map: Map<Int, V>) {
    var out = new cs.system.collections.generic.Dictionary_2<Int, V>();
    this = toNativeMap(map, out);
  }

  @:to
  function toHaxe(): Map<Int, V> {
    var out = new Map<Int, V>();
    return toMap(this, out);
  }
}
#elseif python
function toNativeMap<K, V>(map: Map<K, V>, out: python.Dict<K, V>) {
  for (k => v in map) {
    out.set(k, v);
  }
  return out;
}

function toMap<K, V>(map: python.Dict<K, V>, out: Map<K, V>) {
  for (entry in map.items()) {
    out[entry._1] = entry._2;
  }
  return out;
}

abstract NativeStringMap<V>(python.Dict<String, V>) to python.Dict<String, V> {
  public function new(map: Map<String, V>) {
    var out = new python.Dict<String, V>();
    this = toNativeMap(map, out);
  }

  @:from
  static function fromHaxe(map) {
    return new NativeStringMap(map);
  }

  @:to
  public function toHaxe(): Map<String, V> {
    var out = new Map<String, V>();
    return toMap(this, out);
  }
}

abstract NativeIntMap<V>(python.Dict<Int, V>) {
  public function new(map: Map<Int, V>) {
    var out = new python.Dict<Int, V>();
    this = toNativeMap(map, out);
  }

  @:to
  function toHaxe(): Map<Int, V> {
    var out = new Map<Int, V>();
    return toMap(this, out);
  }
}
#elseif php
abstract NativeStringMap<V>(php.NativeAssocArray<V>) {
  public function new(map: Map<String, V>) {
    var out = new php.NativeAssocArray<V>();
    for (k => v in map) {
      out[k] = v;
    }
    this = out;
  }

  @:from
  static function fromHaxe(map) {
    return new NativeStringMap(map);
  }

  @:to
  public function toHaxe(): Map<String, V> {
    var out = new Map<String, V>();
    for (k => v in this) {
      out[k] = v;
    }
    return out;
  }
}

abstract NativeIntMap<V>(php.NativeIndexedArray<V>) {
  public function new(map: Map<Int, V>) {
    var out = new php.NativeIndexedArray<V>();
    for (k => v in map) {
      out[k] = v;
    }
    this = out;
  }

  @:to
  function toHaxe(): Map<Int, V> {
    var out = new Map<Int, V>();
    for (k => v in this) {
      out[k] = v;
    }
    return out;
  }
}
#elseif cpp
abstract NativeStringMap<V>(Map<String, V>) from Map<String, V> to Map<String, V> {
  public inline function new(a: Map<String, V>) {
    this = a;
  }

  public inline function toHaxe(): Map<String, V> {
    return this;
  }
}

abstract NativeIntMap<V>(Map<Int, V>) to Map<Int, V> {
  public inline function new(a: Map<Int, V>) {
    this = a;
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
@:forward(iterator)
abstract NativeList<T>(java.util.List<T>) from java.util.List<T> to java.util.List<T> {
  public function new(lst: Array<T>) {
    var out = new java.util.ArrayList<T>();
    for (e in lst) {
      out.add(e);
    }
    this = out;
  }

  @:to
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
#elseif cpp
abstract NativeList<T>(Array<T>) {
  public inline function new(a: Array<T>) {
    this = a;
  }

  public inline function toHaxe(): Array<T> {
    return this;
  }
}
#end

#if js
abstract NativeArray<T>(Array<T>) {
  @:from
  public static inline function fromHaxeArray<T>(a: Array<T>) {
    return new NativeArray(a);
  }

  @:to
  public inline function toHaxeArray() {
    return toHaxe();
  }

  public inline function new(a: Array<T>) {
    this = a.copy();
  }

  public inline function toHaxe(): Array<T> {
    return this.copy();
  }
}
#elseif java
abstract NativeArray<T>(java.NativeArray<T>) {
  @:from
  public static inline function fromHaxeArray<T>(a: Array<T>) {
    return new NativeArray(a);
  }

  @:to
  public inline function toHaxeArray() {
    return toHaxe();
  }

  public inline function new(a: Array<T>) {
    this = java.Lib.nativeArray(a, true);
  }

  public function toHaxe(): Array<T> {
    var a = [];
    for (i in 0...this.length) {
      a[i] = this[i];
    }
    return a;
  }
}
#elseif cs
abstract NativeArray<T>(cs.NativeArray<T>) {
  @:from
  public static inline function fromHaxeArray<T>(a: Array<T>) {
    return new NativeArray(a);
  }

  @:to
  public inline function toHaxeArray() {
    return toHaxe();
  }

  public inline function new(a: Array<T>) {
    this = cs.Lib.nativeArray(a, true);
  }

  public inline function toHaxe(): Array<T> {
    return cs.Lib.array(this);
  }
}
#elseif python
abstract NativeArray<T>(Array<T>) {
  @:from
  public static inline function fromHaxeArray<T>(a: Array<T>) {
    return new NativeArray(a);
  }

  @:to
  public inline function toHaxeArray() {
    return toHaxe();
  }

  public inline function new(a: Array<T>) {
    this = a.copy();
  }

  public inline function toHaxe(): Array<T> {
    return this.copy();
  }
}
#elseif php
abstract NativeArray<T>(php.NativeArray) {
  @:from
  public static inline function fromHaxeArray<T>(a: Array<T>) {
    return new NativeArray(a);
  }

  @:to
  public inline function toHaxeArray() {
    return toHaxe();
  }
  
  public inline function new(a: Array<T>) {
    this = php.Lib.toPhpArray(a);
  }

  public inline function toHaxe(): Array<T> {
    return php.Lib.toHaxeArray(this);
  }
}
#elseif cpp
abstract NativeArray<T>(Array<T>) from Array<T> to Array<T> {
  public inline function new(a: Array<T>) {
    this = a;
  }

  public inline function toHaxe(): Array<T> {
    return this;
  }
}
#end

#if java
typedef NativeURI = java.net.URI;
typedef NativeCookieCollection = NativeList<java.net.HttpCookie>;
#elseif LS_NODE
typedef NativeURI = String;
typedef NativeCookieCollection = Array<String>;
#elseif cs
typedef NativeURI = cs.system.Uri;
typedef NativeCookieCollection = cs.system.net.CookieCollection;
#elseif python
typedef NativeURI = String;
typedef NativeCookieCollection = com.lightstreamer.internal.SimpleCookie;
#end

#if java
typedef NativeTrustManager = java.javax.net.ssl.TrustManagerFactory;
#elseif cs
typedef NativeTrustManager = cs.system.net.security.RemoteCertificateValidationCallback;
#elseif python
typedef NativeTrustManager = com.lightstreamer.internal.SSLContext;
#end

#if java
private class RunnableImpl implements java.lang.Runnable {
  final task: ()->Void;

  public function new(task: ()->Void) {
    this.task = task;
  }

	public function run() {
    task();
  }
}

@:forward(run)
abstract NativeFuture(java.util.concurrent.FutureTask<Dynamic>) {
  public function new(task: ()->Void) {
    this = new java.util.concurrent.FutureTask<Dynamic>(new RunnableImpl(task), null);
  }
}
#elseif cs
abstract NativeFuture(cs.system.threading.tasks.Task) {
  public function new(task: ()->Void) {
    this = new cs.system.threading.tasks.Task(task);
  }

  inline public function run() {
    this.Start();
  }
}
#end