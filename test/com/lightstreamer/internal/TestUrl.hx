package com.lightstreamer.internal;

class TestUrl extends utest.Test {
  
  function testAddPathToBase() {
    var url = new Url("http://example.com");
    equals("http://example.com/", url.href);

    url = new Url("http://example.com", "foo");
    equals("http://example.com/foo", url.href);

    url = new Url("http://example.com/", "foo");
    equals("http://example.com/foo", url.href);

    url = new Url("http://example.com", "/foo");
    equals("http://example.com/foo", url.href);

    url = new Url("http://example.com/", "/foo");
    equals("http://example.com/foo", url.href);
  }

  function testParseUrl() {
    var url = new Url("http://example.com:8080/foo");
    equals("http://example.com:8080/foo", url.href);
    equals("http:", url.protocol);
    equals("example.com", url.hostname);
    equals("8080", url.port);
    equals("/foo", url.pathname);

    url = new Url("http://example.com");
    equals("", url.port);
    equals("/", url.pathname);
  }

  function testBuildUrl() {
    var url = new Url("http://example.com");
    url.protocol = "https";
    url.hostname = "foo.org";
    url.port = "8080";
    url.pathname = "bar";
    equals("https://foo.org:8080/bar", url.href);
  }

  function testCompleteControlLink() {
    equals("http://foo.com/", Url.completeControlLink("foo.com", "http://base.it"));
    equals("https://foo.com/", Url.completeControlLink("foo.com", "https://base.it"));
    equals("http://foo.com:80/", Url.completeControlLink("foo.com", "http://base.it:80"));
    equals("http://foo.com:80/", Url.completeControlLink("foo.com", "http://base.it:80/path"));
    
    equals("https://foo.com/", Url.completeControlLink("https://foo.com", "http://base.it"));
    equals("http://foo.com/", Url.completeControlLink("http://foo.com", "https://base.it"));
    equals("http://foo.com:8080/", Url.completeControlLink("foo.com:8080", "http://base.it:80"));
    equals("http://foo.com:80/bar", Url.completeControlLink("foo.com/bar", "http://base.it:80/path"));
  }
}