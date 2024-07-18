package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes.NativeURI;
import com.lightstreamer.internal.NativeTypes.NativeCookieCollection;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class CookieHelper {
  public static final instance = new CookieHelper();

  final jar = new CookieJar();

  function new() {}

  public function addCookies(url: NativeURI, setCookies: NativeCookieCollection): Void {
    var url = new Url(url);
    var cookies = Cookie.fromSetCookies(setCookies);
    jar.setCookiesFromUrl(url, cookies);
  }

  public function getCookieHeader(url: NativeURI): String {
    var url = new Url(url);
    var cookies = jar.cookiesForUrl(url);
    return Cookie.toCookie(cookies);
  }

  public function getCookies(url: NativeURI): NativeCookieCollection {
    var url = new Url(url);
    return jar.cookiesForUrl(url).map(c -> c.toString());
  }

  public function clearCookies(): Void {
    jar.clearAllCookies();
  }
}