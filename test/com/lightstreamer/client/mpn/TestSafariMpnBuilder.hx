package com.lightstreamer.client.mpn;

import com.lightstreamer.client.NativeTypes.NativeList;

class TestSafariMpnBuilder extends utest.Test {
  var b: SafariMpnBuilder;

  function setup() {
    b = new SafariMpnBuilder();
  }

  function testCtor() {
    b = new SafariMpnBuilder();
    equals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder(null);
    equals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("null");
    equals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("{}");
    equals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("{\"foo\":123}");
    equals("{\"foo\":123,\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("{\"aps\":{\"alert\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"url-args\":[\"VAL\"]}}");
    equals("BODY", b.getBody());
    equals("TITLE", b.getTitle());
    strictSame(["VAL"], b.getUrlArguments().toHaxe());
    equals("{\"aps\":{\"alert\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"url-args\":[\"VAL\"]}}", b.build());
  }

  function testBuild() {
    b.setTitle("TITLE");
    b.setBody("BODY");
    equals("{\"aps\":{\"alert\":{\"title\":\"TITLE\",\"body\":\"BODY\"}}}", b.build());

    b.setTitle(null);
    equals("{\"aps\":{\"alert\":{\"body\":\"BODY\"}}}", b.build());
  }

  function testTitle() {
    equals(null, b.getTitle());

    b.setTitle("VAL");
    equals("VAL", b.getTitle());
    equals("{\"aps\":{\"alert\":{\"title\":\"VAL\"}}}", b.build());

    b.setTitle(null);
    equals(null, b.getTitle());
    equals("{\"aps\":{\"alert\":{}}}", b.build());
  }

  function testBody() {
    equals(null, b.getBody());

    b.setBody("VAL");
    equals("VAL", b.getBody());
    equals("{\"aps\":{\"alert\":{\"body\":\"VAL\"}}}", b.build());

    b.setBody(null);
    equals(null, b.getBody());
    equals("{\"aps\":{\"alert\":{}}}", b.build());
  }

  function testAction() {
    equals(null, b.getAction());

    b.setAction("VAL");
    equals("VAL", b.getAction());
    equals("{\"aps\":{\"alert\":{\"action\":\"VAL\"}}}", b.build());

    b.setAction(null);
    equals(null, b.getAction());
    equals("{\"aps\":{\"alert\":{}}}", b.build());
  }

  function testUrlArguments() {
    equals(null, b.getUrlArguments());
    
    b.setUrlArguments(new NativeList(["VAL"]));
    strictSame(["VAL"], b.getUrlArguments().toHaxe());
    equals("{\"aps\":{\"alert\":{},\"url-args\":[\"VAL\"]}}", b.build());
    
    b.setUrlArguments(null);
    equals(null, b.getUrlArguments());
    equals("{\"aps\":{\"alert\":{}}}", b.build());
  }
}