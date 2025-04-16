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