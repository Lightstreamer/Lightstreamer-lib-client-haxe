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

class TestMpnBuilderFirebase extends utest.Test {
  var b: FirebaseMpnBuilder;

  function setup() {
    b = new FirebaseMpnBuilder();
  }

  function testCtor() {
    b = new FirebaseMpnBuilder();
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder(null);
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("null");
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("{}");
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("{\"foo\":123}");
    jsonEquals("{\"foo\":123,\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("{\"webpush\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"data\":{\"KEY\":\"VAL\"}}}");
    equals("BODY", b.getBody());
    equals("TITLE", b.getTitle());
    strictSame(["KEY" => "VAL"], b.getData());
    jsonEquals("{\"webpush\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"data\":{\"KEY\":\"VAL\"}}}", b.build());
  }

  function testBuild() {
    b.setTitle("TITLE");
    b.setBody("BODY");
    jsonEquals("{\"webpush\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"}}}", b.build());

    b.setTitle(null);
    jsonEquals("{\"webpush\":{\"notification\":{\"body\":\"BODY\"}}}", b.build());
  }

  function testHeaders() {
    equals(null, b.getHeaders());

    b.setHeaders(["KEY" => "VAL"]);
    strictSame(["KEY" => "VAL"], b.getHeaders());
    jsonEquals("{\"webpush\":{\"notification\":{},\"headers\":{\"KEY\":\"VAL\"}}}", b.build());

    b.setHeaders(null);
    equals(null, b.getHeaders());
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testTitle() {
    equals(null, b.getTitle());

    b.setTitle("VAL");
    equals("VAL", b.getTitle());
    jsonEquals("{\"webpush\":{\"notification\":{\"title\":\"VAL\"}}}", b.build());

    b.setTitle(null);
    equals(null, b.getTitle());
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testBody() {
    equals(null, b.getBody());

    b.setBody("VAL");
    equals("VAL", b.getBody());
    jsonEquals("{\"webpush\":{\"notification\":{\"body\":\"VAL\"}}}", b.build());

    b.setBody(null);
    equals(null, b.getBody());
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testIcon() {
    equals(null, b.getIcon());

    b.setIcon("VAL");
    equals("VAL", b.getIcon());
    jsonEquals("{\"webpush\":{\"notification\":{\"icon\":\"VAL\"}}}", b.build());

    b.setIcon(null);
    equals(null, b.getIcon());
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testData() {
    equals(null, b.getData());

    b.setData(["KEY" => "VAL"]);
    strictSame(["KEY" => "VAL"], b.getData());
    jsonEquals("{\"webpush\":{\"notification\":{},\"data\":{\"KEY\":\"VAL\"}}}", b.build());

    b.setData(null);
    equals(null, b.getData());
    jsonEquals("{\"webpush\":{\"notification\":{}}}", b.build());
  }
}