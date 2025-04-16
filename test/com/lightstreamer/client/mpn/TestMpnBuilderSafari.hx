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
package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.NativeTypes.NativeList;

class TestMpnBuilderSafari extends utest.Test {
  var b: SafariMpnBuilder;

  function setup() {
    b = new SafariMpnBuilder();
  }

  function testCtor() {
    b = new SafariMpnBuilder();
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder(null);
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("null");
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("{}");
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("{\"foo\":123}");
    jsonEquals("{\"foo\":123,\"aps\":{\"alert\":{}}}", b.build());

    b = new SafariMpnBuilder("{\"aps\":{\"alert\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"url-args\":[\"VAL\"]}}");
    equals("BODY", b.getBody());
    equals("TITLE", b.getTitle());
    strictSame(["VAL"], b.getUrlArguments().toHaxe());
    jsonEquals("{\"aps\":{\"alert\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"url-args\":[\"VAL\"]}}", b.build());
  }

  function testBuild() {
    b.setTitle("TITLE");
    b.setBody("BODY");
    jsonEquals("{\"aps\":{\"alert\":{\"title\":\"TITLE\",\"body\":\"BODY\"}}}", b.build());

    b.setTitle(null);
    jsonEquals("{\"aps\":{\"alert\":{\"body\":\"BODY\"}}}", b.build());
  }

  function testTitle() {
    equals(null, b.getTitle());

    b.setTitle("VAL");
    equals("VAL", b.getTitle());
    jsonEquals("{\"aps\":{\"alert\":{\"title\":\"VAL\"}}}", b.build());

    b.setTitle(null);
    equals(null, b.getTitle());
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());
  }

  function testBody() {
    equals(null, b.getBody());

    b.setBody("VAL");
    equals("VAL", b.getBody());
    jsonEquals("{\"aps\":{\"alert\":{\"body\":\"VAL\"}}}", b.build());

    b.setBody(null);
    equals(null, b.getBody());
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());
  }

  function testAction() {
    equals(null, b.getAction());

    b.setAction("VAL");
    equals("VAL", b.getAction());
    jsonEquals("{\"aps\":{\"alert\":{\"action\":\"VAL\"}}}", b.build());

    b.setAction(null);
    equals(null, b.getAction());
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());
  }

  function testUrlArguments() {
    equals(null, b.getUrlArguments());
    
    b.setUrlArguments(new NativeList(["VAL"]));
    strictSame(["VAL"], b.getUrlArguments().toHaxe());
    jsonEquals("{\"aps\":{\"alert\":{},\"url-args\":[\"VAL\"]}}", b.build());
    
    b.setUrlArguments(null);
    equals(null, b.getUrlArguments());
    jsonEquals("{\"aps\":{\"alert\":{}}}", b.build());
  }
}