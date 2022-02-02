package com.lightstreamer.client.mpn;

class TestFirebaseMpnBuilder extends utest.Test {
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