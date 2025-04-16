/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
    var _uri = new URL(uri);
    store.setCookies(cookies, _uri.hostname, _uri.pathname);
    if (cookieLogger.isDebugEnabled()) {
      logCookies("After adding cookies for " + uri, store.getCookies(CookieAccessInfo.All));
    }
  }

  public function getCookies(uri: Null<String>): Array<String> {
    var info;
    if (uri == null) {
      info = CookieAccessInfo.All;
    } else {
      var _uri = new URL(uri);
      info = new CookieAccessInfo(_uri.hostname, _uri.pathname);
    }
    return store.getCookies(info).map(c -> c.toString());
  }

  public function getCookieHeader(url: String): Option<String> {
    var _url = new URL(url);
    var cookies = store.getCookies(new CookieAccessInfo(_url.hostname, _url.pathname));
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