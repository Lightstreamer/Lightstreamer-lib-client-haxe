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

import com.lightstreamer.cs.CookieHelper as CookieHelperCs;

abstract CookieHelper(CookieHelperCs) {
  public static final instance = new CookieHelper();

  function new() {
    this = CookieHelperCs.instance;
  }

  public function addCookies(uri: cs.system.Uri, cookies: cs.system.net.CookieCollection): Void {
    this.AddCookies(uri, cookies);
  }

  public function getCookies(uri: cs.system.Uri): cs.system.net.CookieCollection {
    return this.GetCookies(uri);
  }

  public function clearCookies(uri: String): Void {
    this.ClearCookies(uri);
  }
}