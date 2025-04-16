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
package cookiejar;

import haxe.extern.EitherType;

/**
class to hold numerous cookies from multiple domains correctly
 */
@:jsRequire("cookiejar", "CookieJar")
extern class CookieJar {
  function new();
  /**
  modify (or add if not already-existing) a cookie to the jar
   */
  function setCookie(cookie: EitherType<Cookie, String>, ?request_domain: String, ?request_path: String): Cookie;
  /**
  modify (or add if not already-existing) a large number of cookies to the jar
   */
  function setCookies(cookies: EitherType<Array<Cookie>, EitherType<Array<String>, String>>, ?request_domain: String, ?request_path: String): Array<Cookie>;
  /**
   get a cookie with the name and access_info matching
   */
  function getCookie(cookie_name: String, access_info: CookieAccessInfo): Cookie;
  /**
  grab all cookies matching this access_info
   */
  function getCookies(access_info: CookieAccessInfo): Array<Cookie>;
}