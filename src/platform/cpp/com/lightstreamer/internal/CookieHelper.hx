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