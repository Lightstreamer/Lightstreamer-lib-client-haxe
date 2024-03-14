package com.lightstreamer.internal;

import com.lightstreamer.hxpoco.HttpClientCpp;
import com.lightstreamer.internal.NativeTypes;

@:unreflective
class CookieHelper {
  public static final instance = new CookieHelper();

  function new() {}

  inline public function addCookies(url: cpp.Reference<NativeURI>, cookies: cpp.Reference<NativeCookieCollection>): Void {
    HttpClientCpp._cookieJar.setCookiesFromUrl(url, cookies);
  }

  inline public function getCookies(url: cpp.Reference<NativeURI>): NativeCookieCollection {
    return HttpClientCpp._cookieJar.cookiesForUrl(url);
  }

  inline public function clearCookies(): Void {
    HttpClientCpp._cookieJar.clearAllCookies();
  }
}