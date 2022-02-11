package com.lightstreamer.client.internal;

import java.net.HttpCookie;
import com.lightstreamer.client.NativeTypes.NativeList;

class TestCookieHelper extends utest.Test {
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