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

  // TODO logging
  // TODO addCookies/getCookies

  public function setCookies(url: String, cookies: EitherType<String, Array<String>>) {
    var _url = new URL(url);
    store.setCookies(cookies, _url.hostname);
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
    return cookie != "" ? Some(cookie) : None;
  }

  function logCookies(message: String, cookies: Array<Cookie>) {
    for (cookie in cookies) {
      message += ("\r\n    " + cookie.toString());
    }
    cookieLogger.logDebug(message);
  }
}