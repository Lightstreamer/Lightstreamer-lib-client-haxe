package com.lightstreamer.internal;

@:access(com.lightstreamer.internal.RequestBuilder)
class TestRequestBuilder extends utest.Test {
  function testEncoding() {
    var req = new RequestBuilder();
    req.addParam("a", "f&=o");
    req.addParam("b", "b +r");
    req.addParam("c", 123);
    req.addParam("d", 456.7);
    req.addParam("e", true);
    equals("a=f%26%3Do&b=b%20%2Br&c=123&d=456.7&e=true", req.getEncodedString());
  }
}