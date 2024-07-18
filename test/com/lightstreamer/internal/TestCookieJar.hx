package com.lightstreamer.internal;

import com.lightstreamer.internal.Cookie;

using com.lightstreamer.internal.TestCookieJar.TestCookieJarHelper;

@:publicFields
private class TestCookieJarHelper {
  static function size<T>(a: Array<T>) return a.length;
  static function at<T>(a: Array<T>, i: Int) return a[i];
}

class TestCookieJar extends utest.Test {

  function testAddCookies() {
    var jar = new CookieJar();
    var url1 = new Url("http://acme.com");
    var url2 = new Url("http://foo.bar");
    var c1 = new Cookie({name:"n1", value:"v1"});
    var c2 = new Cookie({name:"n2", value:"v2"});
    jar.setCookiesFromUrl(url1, [ c1 ]);
    jar.setCookiesFromUrl(url2, [ c2 ]);
    {
      var v = jar.cookiesForUrl(url1);
      equals(1, v.size());
      equals("n1=v1; domain=acme.com; path=/", v.at(0).toString());
    }
    {
      var v = jar.cookiesForUrl(url2);
      equals(1, v.size());
      equals("n2=v2; domain=foo.bar; path=/", v.at(0).toString());
    }
  }

  function testAddTwice() {
    var jar = new CookieJar();
    var url = new Url("http://acme.com");
    var c1 = new Cookie({name:"n1", value:"v1"});
    jar.setCookiesFromUrl(url, [ c1 ]);
    {
      var v = jar.cookiesForUrl(url);
      equals(1, v.size());
      equals("n1=v1; domain=acme.com; path=/", v.at(0).toString());
    }
    var c2 = new Cookie({name:"n1", value:"v2"});
    jar.setCookiesFromUrl(url, [ c2 ]);
    {
      var v = jar.cookiesForUrl(url);
      equals(1, v.size());
      equals("n1=v2; domain=acme.com; path=/", v.at(0).toString());
    }
  }

  function testAddSameNameDifferentPaths() {
    var jar = new CookieJar();
    var url = new Url("http://acme.com");
    var c1 = new Cookie({name:"n1", value:"v1", path:"/"});
    var c2 = new Cookie({name:"n1", value:"v2", path:"/foo"});
    var c3 = new Cookie({name:"n1", value:"v3", path:"/foo/bar"});
    jar.setCookiesFromUrl(url, [ c1, c2, c3 ]);
    {
      var v = jar.cookiesForUrl(new Url("http://acme.com/foo/bar"));
      equals(3, v.size());
      // NB cookies are returned according to the length of their paths
      equals("n1=v3; domain=acme.com; path=/foo/bar", v.at(0).toString());
      equals("n1=v2; domain=acme.com; path=/foo", v.at(1).toString());
      equals("n1=v1; domain=acme.com; path=/", v.at(2).toString());
    }
  }

  function testDeleteCookies() {
    var jar = new CookieJar();
    var url = new Url("http://acme.com");
    var c1 = new Cookie({name: "n1", value: "v1"});
    jar.setCookiesFromUrl(url, [ c1 ]);
    {
      var v = jar.cookiesForUrl(url);
      equals(1, v.size());
      equals("n1=v1; domain=acme.com; path=/", v.at(0).toString());
    }
    {
      // a cookie is deleted by setting its age to 0
      jar.setCookiesFromUrl(url, [ new Cookie({name: "n1", value: "v1", maxAge: 0}) ]);
      var v = jar.cookiesForUrl(url);
      equals(0, v.size());
    }
  }

  function testClearCookies() {
    var jar = new CookieJar();
    var url = new Url("http://acme.com");
    var c1 = new Cookie({name: "n1", value: "v1"});
    jar.setCookiesFromUrl(url, [ c1 ]);
    equals(1, jar.cookiesForUrl(url).size());
    jar.clearAllCookies();
    equals(0, jar.cookiesForUrl(url).size());
  }

  function testSecureCookies() {
    var jar = new CookieJar();
    var url1 = new Url("http://acme.com");
    var url2 = new Url("https://acme.com");
    var c1 = new Cookie({name: "n1", value: "v1", secure: false});
    var c2 = new Cookie({name: "n2", value: "v2", secure: true});
    jar.setCookiesFromUrl(url1, [ c1, c2 ]);
    {
      var v = jar.cookiesForUrl(url1);
      equals(1, v.size());
      equals("n1=v1; domain=acme.com; path=/", v.at(0).toString());
    }
    {
      var v = jar.cookiesForUrl(url2);
      equals(2, v.size());
      equals("n1=v1; domain=acme.com; path=/", v.at(0).toString());
      equals("n2=v2; domain=acme.com; path=/; secure", v.at(1).toString());
    }
  }

  function testCookieDomain() {
    var jar = new CookieJar();
    var url1 = new Url("http://acme.com");
    var url2 = new Url("http://sub.acme.com");
    var url3 = new Url("http://www.sub.acme.com");
    var c1 = new Cookie({name:"n1", value:"v1", domain:"acme.com"});
    var c2 = new Cookie({name:"n2", value:"v2", domain:"sub.acme.com"});
    jar.setCookiesFromUrl(url2, [ c1, c2 ]);
    {
      var v = jar.cookiesForUrl(url1);
      equals(1, v.size());
      equals("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
    }
    {
      var v = jar.cookiesForUrl(url2);
      equals(2, v.size());
      equals("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
      equals("n2=v2; domain=.sub.acme.com; path=/", v.at(1).toString());
    }
    {
      var v = jar.cookiesForUrl(url3);
      equals(2, v.size());
      equals("n1=v1; domain=.acme.com; path=/", v.at(0).toString());
      equals("n2=v2; domain=.sub.acme.com; path=/", v.at(1).toString());
    }
  }

  function testCookiePath() {
    var jar = new CookieJar();
    var url1 = new Url("http://acme.com");
    var url2 = new Url("http://acme.com/foo");
    var url3 = new Url("http://acme.com/foo/bar");
    var c1 = new Cookie({name:"n1", value:"v1", path:"/"});
    var c2 = new Cookie({name:"n2", value:"v2", path:"/foo"});
    jar.setCookiesFromUrl(url2, [ c1, c2 ]);
    {
      var v = jar.cookiesForUrl(url1);
      equals(1, v.size());
      equals("n1=v1; domain=acme.com; path=/", v.at(0).toString());
    }
    {
      var v = jar.cookiesForUrl(url2);
      equals(2, v.size());
      equals("n2=v2; domain=acme.com; path=/foo", v.at(0).toString());
      equals("n1=v1; domain=acme.com; path=/", v.at(1).toString());
    }
    {
      var v = jar.cookiesForUrl(url3);
      equals(2, v.size());
      equals("n2=v2; domain=acme.com; path=/foo", v.at(0).toString());
      equals("n1=v1; domain=acme.com; path=/", v.at(1).toString());
    }
  }

  function testCookieExpirationDate() {
    var jar = new CookieJar();
    var url = new Url("http://acme.com");
    var c1 = new Cookie({name:"n1", value:"v1", maxAge:0}); // expired
    var c2 = new Cookie({name:"n2", value:"v2", maxAge:1}); // expiring after 1 second
    var c3 = new Cookie({name:"n3", value:"v3"}); // session cookie
    jar.setCookiesFromUrl(url, [ c1, c2, c3 ]);
    {
      var v = jar.cookiesForUrl(url);
      equals(2, v.size());
      equals("n2", v.at(0).name);
      equals("n3", v.at(1).name);
    }
    {
      Sys.sleep(1);
      var v = jar.cookiesForUrl(url);
      equals(1, v.size());
      equals("n3", v.at(0).name);
    }
  }
}