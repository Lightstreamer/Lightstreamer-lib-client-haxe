package com.lightstreamer.native;

#if java
abstract Long(java.StdTypes.Int64) from Int {}
#elseif cs
abstract Long(cs.StdTypes.Int64) from Int {}
#elseif python
/**
 * Alias for [int](https://docs.python.org/3/library/functions.html#int).
 */
abstract Long(Int) from Int {}
#else
abstract Long(Int) from Int {}
#end

#if js
abstract NativeException(js.lib.Error) {}
#elseif java
abstract NativeException(java.lang.Throwable) {}
#elseif cs
abstract NativeException(cs.system.Exception) {}
#elseif python
/**
 * Alias for [BaseException](https://docs.python.org/3/library/exceptions.html#BaseException).
 */
abstract NativeException(python.Exceptions.BaseException) {}
#elseif php
abstract NativeException(php.Throwable) {}
#elseif cpp
abstract NativeException(Any) {}
#end

#if java
abstract IllegalArgumentException(java.lang.IllegalArgumentException) {}
abstract IllegalStateException(java.lang.IllegalStateException) {}
#elseif cs
abstract IllegalArgumentException(cs.system.ArgumentException) {}
abstract IllegalStateException(cs.system.InvalidOperationException) {}
#else
/**
 * Thrown to indicate that a method has been passed an illegal 
 * or inappropriate argument.
 * <BR>Use toString to extract details on the error occurred.
 */
class IllegalArgumentException extends haxe.Exception {}
/**
 * Thrown to indicate that a method has been invoked at an illegal or 
 * inappropriate time or that the internal state of an object is incompatible 
 * with the call.
 * <BR>Use toString to extract details on the error occurred.
 */
class IllegalStateException extends haxe.Exception {}
#end

#if js
abstract NativeStringMap(haxe.DynamicAccess<String>) {}
#elseif java
abstract NativeStringMap1<V>(java.util.Map<String, V>) {}

abstract NativeIntMap1<V>(java.util.Map<Int, V>) {}

abstract NativeStringMap(java.util.Map<String, String>) {}
#elseif cs
abstract NativeStringMap1<V>(cs.system.collections.generic.IDictionary_2<String, V>) {}

abstract NativeIntMap1<V>(cs.system.collections.generic.IDictionary_2<Int, V>) {}

abstract NativeStringMap(cs.system.collections.generic.IDictionary_2<String, String>) 
to cs.system.collections.generic.IDictionary_2<String, String> {}
#elseif python
/**
 * Alias for [dict&lt;String, V&gt;](https://docs.python.org/3/library/stdtypes.html#mapping-types-dict).
 */
abstract NativeStringMap1<V>(python.Dict<String, V>) {}
/**
 * Alias for [dict&lt;Int, V&gt;](https://docs.python.org/3/library/stdtypes.html#mapping-types-dict).
 */
abstract NativeIntMap1<V>(python.Dict<Int, V>) {}
/**
 * Alias for [dict&lt;String, String&gt;](https://docs.python.org/3/library/stdtypes.html#mapping-types-dict).
 */
abstract NativeStringMap(python.Dict<String, String>) {}
#elseif php
abstract NativeStringMap1<V>(php.NativeAssocArray<V>) {}

abstract NativeIntMap1<V>(php.NativeIndexedArray<V>) {}

abstract NativeStringMap(php.NativeAssocArray<String>) {}
#elseif cpp
abstract NativeStringMap1<V>(Map<String, V>) to Map<String, V> {}

abstract NativeIntMap1<V>(Map<Int, V>) to Map<Int, V> {}

abstract NativeStringMap(Map<String, String>) {}
#end

#if js
abstract NativeList<T>(Array<T>) {}
#elseif java
abstract NativeList<T>(java.util.List<T>) {}
#elseif cs
abstract NativeList<T>(cs.system.collections.generic.IList_1<T>) {}
#elseif python
/**
 * Alias for [list](https://docs.python.org/3/library/stdtypes.html#list).
 */
abstract NativeList<T>(Array<T>) {}
#elseif php
abstract NativeList<T>(php.NativeIndexedArray<T>) {}
#elseif cpp
abstract NativeList<T>(Array<T>) {}
#end

#if js
abstract NativeArray<T>(Array<T>) {}
#elseif java
abstract NativeArray<T>(java.NativeArray<T>) {}
#elseif cs
abstract NativeArray<T>(cs.NativeArray<T>) {}
#elseif python
/**
 * Alias for [list](https://docs.python.org/3/library/stdtypes.html#list).
 */
abstract NativeArray<T>(Array<T>) {}
#elseif php
abstract NativeArray<T>(php.NativeArray) {}
#elseif cpp
abstract NativeArray<T>(Array<T>) {}
#end

#if java
abstract NativeURI(java.net.URI) {}
abstract NativeCookieCollection(NativeList<java.net.HttpCookie>) {}
#elseif LS_NODE
abstract NativeURI(String) {}
abstract NativeCookieCollection(Array<String>) {}
#elseif cs
abstract NativeURI(cs.system.Uri) {}
abstract NativeCookieCollection(cs.system.net.CookieCollection) {}
#elseif python
/**
 * Alias for [string](https://docs.python.org/3/library/string.html?#module-string).
 */
abstract NativeURI(String) {}
/**
 * Alias for [http.cookies.SimpleCookie](https://docs.python.org/3/library/http.cookies.html#http.cookies.SimpleCookie).
 */
abstract NativeCookieCollection(SimpleCookie) {}
#end

#if java
abstract NativeTrustManager(java.javax.net.ssl.TrustManagerFactory) {}
#elseif cs
abstract NativeTrustManager(cs.system.net.security.RemoteCertificateValidationCallback) {}
#elseif python
/**
 * Alias for [ssl.SSLContext](https://docs.python.org/3/library/ssl.html#ssl.SSLContext).
 */
abstract NativeTrustManager(SSLContext) {}
#end

#if python
@:dox(hide)
extern class SimpleCookie {}
@:dox(hide)
extern class SSLContext {}
#end