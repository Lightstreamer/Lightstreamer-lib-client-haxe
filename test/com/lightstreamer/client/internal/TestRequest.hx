package com.lightstreamer.client.internal;

class TestRequest extends utest.Test {

  function testAdd() {
    var req = new Request();
    req.addSubRequest("foo");
    equals("foo", req.getBody());
    req.addSubRequest("bar");
    equals("foo\r\nbar", req.getBody());
  }

  function testConditionalAdd() {
    var req = new Request();
    equals(true, req.addSubRequestOnlyIfBodyIsLessThan("foo", 5));
    equals(false, req.addSubRequestOnlyIfBodyIsLessThan("bar", 5));
    equals("foo", req.getBody());
  }

  function testSurrogatePairs() {
    var req = new Request();
    equals(true, req.addSubRequestOnlyIfBodyIsLessThan("🌉", 10));
    equals(true, req.addSubRequestOnlyIfBodyIsLessThan("🌐", 10));
    equals(false, req.addSubRequestOnlyIfBodyIsLessThan("a", 10));
    equals(10, req.getByteSize());
    equals("🌉\r\n🌐", req.getBody());
  }
}