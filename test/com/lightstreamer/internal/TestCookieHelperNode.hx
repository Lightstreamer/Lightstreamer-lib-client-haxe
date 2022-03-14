package com.lightstreamer.internal;

class TestCookieHelperNode extends utest.Test {
  function testCookies() {
    var uri = "http://www.example.com";
    strictSame([], CookieHelper.instance.getCookies(uri));
    
    var cookie = "Foo=bar";
    CookieHelper.instance.addCookies(uri, [cookie]);
    strictSame(["Foo=bar; domain=www.example.com; path=/"], CookieHelper.instance.getCookies(uri));

    CookieHelper.instance.clearCookies();
    strictSame([], CookieHelper.instance.getCookies(uri));
  }

  function testCookiesWithPath() {
    var uri = "http://www.example.com/ls";
    strictSame([], CookieHelper.instance.getCookies(uri));
    
    var cookie = "Foo=bar";
    CookieHelper.instance.addCookies(uri, [cookie]);
    strictSame(["Foo=bar; domain=www.example.com; path=/ls"], CookieHelper.instance.getCookies(uri));

    CookieHelper.instance.clearCookies();
    strictSame([], CookieHelper.instance.getCookies(uri));
  }
}