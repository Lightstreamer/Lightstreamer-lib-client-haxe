package com.lightstreamer.hxpoco;

import cpp.Reference;
import com.lightstreamer.internal.NativeTypes.NativeURI;
import com.lightstreamer.internal.NativeTypes.NativeCookieCollection;

@:structAccess
@:include("Lightstreamer/HxPoco/CookieJar.h")
@:native("Lightstreamer::HxPoco::CookieJar")
extern class CookieJar {
  function cookiesForUrl(url: Reference<NativeURI>): NativeCookieCollection;
  function setCookiesFromUrl(url: Reference<NativeURI>, cookies: Reference<NativeCookieCollection>): Bool;
  function clearAllCookies(): Void;
}