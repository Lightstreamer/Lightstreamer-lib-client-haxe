package com.lightstreamer.internal;

import com.lightstreamer.internal.Cookie;

// adapted from https://github.com/nfriedly/set-cookie-parser/blob/master/test/set-cookie-parser.js
class TestCookie extends utest.Test {

  // should parse a simple set-cookie header
  function testSimple() {
    var actual = parse("foo=bar;");
    var expected = [new Cookie({ name: "foo", value: "bar" })];
    isTrue(actual[0].equals(expected[0]));
  }

  // should return empty array on falsy input
  function testFalsy() {
    var cookieStr = "";
    var actual = parse(cookieStr);
    var expected = [];
    equals(actual, expected);

    cookieStr = null;
    actual = parse(cookieStr);
    expected = [];
    equals(actual, expected);
  }

  // should parse a complex set-cookie header
  function testComplex() {
    var cookieStr =
      "foo=bar; Max-Age=1000; Domain=.example.com; Path=/; Expires=Tue, 01 Jul 2025 10:01:11 GMT; HttpOnly; Secure";
    var actual = parse(cookieStr);
    var expected = [
      new Cookie({
        name: "foo",
        value: "bar",
        path: "/",
        expires: new Date(2025, 6, 1, 10, 1, 11),
        maxAge: 1000,
        domain: ".example.com",
        secure: true,
        httpOnly: true,
      }),
    ];
    isTrue(actual[0].equals(expected[0]));
  }

  // should parse a weird but valid cookie
  function testWeird() {
    var cookieStr =
      "foo=bar=bar&foo=foo&John=Doe&Doe=John; Max-Age=1000; Domain=.example.com; Path=/; HttpOnly; Secure";
    var actual = parse(cookieStr);
    var expected = [
      new Cookie({
        name: "foo",
        value: "bar=bar&foo=foo&John=Doe&Doe=John",
        path: "/",
        maxAge: 1000,
        domain: ".example.com",
        secure: true,
        httpOnly: true,
      }),
    ];
    isTrue(actual[0].equals(expected[0]));
  }

  // should parse a cookie with percent-encoding in the data
  function testEncoded() {
    var cookieStr = "foo=asdf%3Basdf%3Dtrue%3Basdf%3Dasdf%3Basdf%3Dtrue%40asdf";
    var actual = parse(cookieStr);
    var expected = [
      new Cookie({ name: "foo", value: "asdf;asdf=true;asdf=asdf;asdf=true@asdf" }),
    ];
    isTrue(actual[0].equals(expected[0]));

    actual = parse(cookieStr);
    expected = [
      new Cookie({ name: "foo", value: "asdf;asdf=true;asdf=asdf;asdf=true@asdf" }),
    ];
    isTrue(actual[0].equals(expected[0]));
  }

  @:Ignored
  // should handle the case when value is not UTF-8 encoded
  function testNotUTF8() {
    var cookieStr =
      "foo=R%F3r%EB%80%8DP%FF%3B%2C%23%9A%0CU%8E%A2C8%D7%3C%3C%B0%DF%17%60%F7Y%DB%16%8BQ%D6%1A";
    var actual = parse(cookieStr);
    var expected = [
      new Cookie({
        name: "foo",
        value:
          "R%F3r%EB%80%8DP%FF%3B%2C%23%9A%0CU%8E%A2C8%D7%3C%3C%B0%DF%17%60%F7Y%DB%16%8BQ%D6%1A",
      }),
    ];
    isTrue(actual[0].equals(expected[0]));
  }

  // should have empty name string, and value is the name-value-pair if the name-value-pair string lacks a = character
  function testEmptyName() {
    var actual = parse("foo;");
    var expected: Array<Cookie> = [new Cookie({ name: "", value: "foo" })];

    isTrue(actual[0].equals(expected[0]));

    actual = parse("foo;SameSite=None;Secure");
    expected = [new Cookie({ name: "", value: "foo", sameSite: "None", secure: true })];
    isTrue(actual[0].equals(expected[0]));
  }

  function testToString() {
    var c = new Cookie({name:"n1", value:"v1", maxAge: 123, expires: Date.fromTime(DateTools.makeUtc(2024,6,17,16,33,40))});
    equals("n1=v1; Expires=Wed, 17 Jul 2024 16:33:40 GMT; Max-Age=123", c.toString());
  }
}