package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes;

@:unreflective
class CookieHelper {
  public static final instance = new CookieHelper();

  function new() {}

  inline public function addCookies(url: cpp.Reference<NativeURI>, cookies: cpp.Reference<NativeCookieCollection>): Void {
    HttpClient.setCookiesFromUrl(url, cookies);
  }

  inline public function getCookies(url: cpp.Reference<NativeURI>): NativeCookieCollection {
    return HttpClient.cookiesForUrl(url);
  }

  inline public function clearCookies(): Void {
    HttpClient.clearAllCookies();
  }
}