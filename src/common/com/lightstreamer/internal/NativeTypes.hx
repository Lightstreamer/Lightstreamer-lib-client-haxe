package com.lightstreamer.internal;

#if java
typedef Long = java.StdTypes.Int64;
#elseif cs
typedef Long = cs.StdTypes.Int64;
#else
typedef Long = Int;
#end

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

abstract Exception(ExceptionImpl) from ExceptionImpl {

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
abstract NativeStringMap(haxe.DynamicAccess<String>) {
  @:from
  public static inline function fromHaxeMap(map: Map<String, String>) {
    return new NativeStringMap(map);
  }

  @:to
  public inline function toHaxeMap() {
    return toHaxe();
  }

  public overload inline extern function new(map: Map<String, String>) {
    this = fromMapToDynamicAccess(map);
  }
  
  public overload inline extern function new(map: haxe.DynamicAccess<String>) {
    this = map.copy();
  }

  static function fromMapToDynamicAccess(map: Map<String, String>) {
    var out: haxe.DynamicAccess<String> = {};
    for (k => v in map) {
      out[k] = v;
    }
    return out;
  }

  public function toHaxe(): Map<String, String> {
    var out = new Map<String, String>();
    @:nullSafety(Off) 
    for (k => v in this) {
      out[k] = v;
    }
    return out;
  }

  public function toDynamicAccess(): haxe.DynamicAccess<String> {
    @:nullSafety(Off) return this.copy();
  }
}
#elseif java
abstract NativeMap<K, V>(java.util.Map<K, V>) {
  public function new(map: Map<K, V>) {
    var out = new java.util.HashMap<K, V>();
    for (k => v in map) {
      out.put(k, v);
    }
    this = out;
  }

  public function toHaxe(out: Map<K, V>): Map<K, V> {
    for (entry in this.entrySet()) {
      out[entry.getKey()] = entry.getValue();
    }
    return out;
  }
}

abstract NativeStringMap(java.util.Map<String, String>) {
  @:from
  public static inline function fromHaxeMap(map) {
    return new NativeStringMap(map);
  }

  @:to
  public inline function toHaxeMap() {
    return toHaxe();
  }

  public overload function new(map: Map<String, String>) {
    var out = new java.util.HashMap<String, String>();
    for (k => v in map) {
      out.put(k, v);
    }
    this = out;
  }

  public overload function new(map: haxe.DynamicAccess<String>) {
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

  public function toDynamicAccess(): haxe.DynamicAccess<String> {
    var out = new haxe.DynamicAccess<String>();
    for (entry in this.entrySet()) {
      out[entry.getKey()] = entry.getValue();
    }
    return out;
  }
}
#elseif cs
abstract NativeMap<K, V>(cs.system.collections.generic.IDictionary_2<K, V>) {
  public function new(map: Map<K, V>) {
    var out = new cs.system.collections.generic.Dictionary_2<K, V>();
    for (k => v in map) {
      out.Add(k, v);
    }
    this = out;
  }

  public function toHaxe(out: Map<K, V>): Map<K, V> {
    var it = this.GetEnumerator();
    while (it.MoveNext()) {
      var entry = it.Current;
      out[entry.Key] = entry.Value;
    }
    return out;
  }
}

abstract NativeStringMap(cs.system.collections.generic.IDictionary_2<String, String>) 
to cs.system.collections.generic.IDictionary_2<String, String> {
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
abstract NativeMap<K, V>(python.Dict<K, V>) {
  public function new(map: Map<K, V>) {
    var out = new python.Dict<K, V>();
    for (k => v in map) {
      out.set(k, v);
    }
    this = out;
  }

  public function toHaxe(out: Map<K, V>): Map<K, V> {
    for (entry in this.items()) {
      out[entry._1] = entry._2;
    }
    return out;
  }
}

abstract NativeStringMap(python.Dict<String, String>) to python.Dict<String, String> {
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
@:multiType(@:followWithAbstracts K)
abstract NativeMap<K, V>(haxe.Constraints.IMap<K, V>) {
  public function new(a: Map<K, V>);

  @:to static function toStringMap<K:String, V>(t: haxe.Constraints.IMap<K, V>, a: Map<K, V>): php.NativeAssocArray<V> {
    var res = new php.NativeAssocArray<V>();
    for (k => v in a) {
      res[k] = v;
    }
    return res;
  }

  @:to static function toIntMap<K:Int, V>(t: haxe.Constraints.IMap<K, V>, a: Map<K, V>): php.NativeIndexedArray<V> {
    var res = new php.NativeIndexedArray<V>();
    for (k => v in a) {
      res[k] = v;
    }
    return res;
  }

  public function toHaxe(out: Map<K, V>): Map<K, V> {
    for (k => v in this) {
      out[k] = v;
    }
    return out;
  }
}

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
#elseif cpp
abstract NativeMap<K, V>(Map<K, V>) {
  public inline function new(a: Map<K, V>) {
    this = a;
  }

  public function toHaxe(out: Map<K, V>): Map<K, V> {
    return this;
  }
}

abstract NativeStringMap(Map<String, String>) from Map<String, String> to Map<String, String> {
  public inline function new(a: Map<String, String>) {
    this = a;
  }

  public inline function toHaxe(): Map<String, String> {
    return this;
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