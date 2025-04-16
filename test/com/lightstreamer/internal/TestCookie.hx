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

import com.lightstreamer.internal.Cookie;

// adapted from https://github.com/nfriedly/set-cookie-parser/blob/master/test/set-cookie-parser.js
class TestCookie extends utest.Test {

  // should parse a simple set-cookie header
  function testSimple() {
    var actual = parseSetCookie("foo=bar;");
    var expected = new Cookie({ name: "foo", value: "bar" });
    isTrue(expected.equals(actual));
  }

  // should return empty array on falsy input
  function testFalsy() {
    var cookieStr = "";
    var actual = parseSetCookie(cookieStr);
    isNull(actual);

    cookieStr = null;
    actual = parseSetCookie(cookieStr);
    isNull(actual);
  }

  // should parse a complex set-cookie header
  function testComplex() {
    var cookieStr =
      "foo=bar; Max-Age=1000; Domain=.example.com; Path=/; Expires=Tue, 01 Jul 2025 10:01:11 GMT; HttpOnly; Secure";
    var actual = parseSetCookie(cookieStr);
    var expected = new Cookie({
      name: "foo",
      value: "bar",
      path: "/",
      expires: new Date(2025, 6, 1, 10, 1, 11),
      maxAge: 1000,
      domain: ".example.com",
      secure: true,
      httpOnly: true,
    });
    isTrue(expected.equals(actual));
  }

  // should parse a weird but valid cookie
  function testWeird() {
    var cookieStr =
      "foo=bar=bar&foo=foo&John=Doe&Doe=John; Max-Age=1000; Domain=.example.com; Path=/; HttpOnly; Secure";
    var actual = parseSetCookie(cookieStr);
    var expected = new Cookie({
      name: "foo",
      value: "bar=bar&foo=foo&John=Doe&Doe=John",
      path: "/",
      maxAge: 1000,
      domain: ".example.com",
      secure: true,
      httpOnly: true,
    });
    isTrue(expected.equals(actual));
  }

  // should parse a cookie with percent-encoding in the data
  function testEncoded() {
    var cookieStr = "foo=asdf%3Basdf%3Dtrue%3Basdf%3Dasdf%3Basdf%3Dtrue%40asdf";
    var actual = parseSetCookie(cookieStr);
    var expected = new Cookie({ name: "foo", value: "asdf;asdf=true;asdf=asdf;asdf=true@asdf" });
    isTrue(expected.equals(actual));

    actual = parseSetCookie(cookieStr);
    expected = new Cookie({ name: "foo", value: "asdf;asdf=true;asdf=asdf;asdf=true@asdf" });
    isTrue(expected.equals(actual));
  }

  @:Ignored
  // should handle the case when value is not UTF-8 encoded
  function testNotUTF8() {
    var cookieStr =
      "foo=R%F3r%EB%80%8DP%FF%3B%2C%23%9A%0CU%8E%A2C8%D7%3C%3C%B0%DF%17%60%F7Y%DB%16%8BQ%D6%1A";
    var actual = parseSetCookie(cookieStr);
    var expected = new Cookie({
      name: "foo",
      value:
        "R%F3r%EB%80%8DP%FF%3B%2C%23%9A%0CU%8E%A2C8%D7%3C%3C%B0%DF%17%60%F7Y%DB%16%8BQ%D6%1A",
    });
    isTrue(expected.equals(actual));
  }

  // should have empty name string, and value is the name-value-pair if the name-value-pair string lacks a = character
  function testEmptyName() {
    var actual = parseSetCookie("foo;");
    var expected = new Cookie({ name: "", value: "foo" });
    isTrue(expected.equals(actual));

    actual = parseSetCookie("foo;SameSite=None;Secure");
    expected = new Cookie({ name: "", value: "foo", sameSite: "None", secure: true });
    isTrue(expected.equals(actual));
  }

  function testToString() {
    var c = new Cookie({name:"n1", value:"v1", maxAge: 123, expires: Date.fromTime(DateTools.makeUtc(2024,6,17,16,33,40))});
    equals("n1=v1; Expires=Wed, 17 Jul 2024 16:33:40 GMT; Max-Age=123", c.toString());
  }
}