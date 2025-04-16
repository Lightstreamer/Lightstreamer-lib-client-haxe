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

import java.net.HttpCookie;
import com.lightstreamer.internal.NativeTypes.NativeList;

class TestCookieHelperJava extends utest.Test {
  function testCookies() {
    var uri = new java.net.URI("www.example.com");
    strictSame([], CookieHelper.instance.getCookies(uri));
    
    var cookie = new java.net.HttpCookie("Foo", "bar");
    CookieHelper.instance.addCookies(uri, new NativeList([cookie]));
    strictSame([cookie], CookieHelper.instance.getCookies(uri));

    CookieHelper.instance.clearCookies();
    strictSame([], CookieHelper.instance.getCookies(uri));
  }
}