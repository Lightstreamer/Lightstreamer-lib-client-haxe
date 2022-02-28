package com.lightstreamer.internal;

import haxe.extern.EitherType;
import haxe.ds.Option;
import js.node.url.URL;
import cookiejar.*;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class CookieHelper {
  public static final instance = new CookieHelper();
  final store = new CookieJar();

  function new() {}

  public function addCookies(uri: String, cookies: Array<String>): Void {
    if (cookies.length == 0) {
      return;
    }
    if (cookieLogger.isDebugEnabled()) {
      logCookies("Before adding cookies for " + uri, store.getCookies(CookieAccessInfo.All));
      logCookies2("Cookies to be added for " + uri, cookies);
    }
    store.setCookies(cookies, new URL(uri).hostname);
    if (cookieLogger.isDebugEnabled()) {
      logCookies("After adding cookies for " + uri, store.getCookies(CookieAccessInfo.All));
    }
  }

  public function getCookies(uri: Null<String>): Array<String> {
    var info = uri == null ? CookieAccessInfo.All : new CookieAccessInfo(new URL(uri).hostname);
    return store.getCookies(info).map(c -> c.toString());
  }

  public function getCookieHeader(url: String): Option<String> {
    var _url = new URL(url);
    var cookies = store.getCookies(new CookieAccessInfo(_url.hostname));
    var cookie = "";
    for (ck in cookies) {
        if (ck.secure && _url.protocol != "https:")
            continue;
        if (cookie != "")
            cookie += "; ";
        cookie += ck.toValueString();
    }
    if (cookie != "") {
      cookieLogger.logDebug("Cookie: " + cookie);
    }
    return cookie != "" ? Some(cookie) : None;
  }

  public function clearCookies() {
    var cookies = store.getCookies(CookieAccessInfo.All);
    for (c in cookies) {
      c.expiration_date = 0;
    }
    store.setCookies(cookies);
  }

  function logCookies(message: String, cookies: Array<Cookie>) {
    for (cookie in cookies) {
      message += ("\r\n    " + cookie.toString());
    }
    cookieLogger.logDebug(message);
  }

  function logCookies2(message: String, cookies: Array<String>) {
    for (cookie in cookies) {
      message += ("\r\n    " + cookie);
    }
    cookieLogger.logDebug(message);
  }
}