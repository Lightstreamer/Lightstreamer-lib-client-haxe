package com.lightstreamer.client.mpn;

class TestFirebaseMpnBuilder extends utest.Test {
  var b: FirebaseMpnBuilder;

  function setup() {
    b = new FirebaseMpnBuilder();
  }

  function testCtor() {
    b = new FirebaseMpnBuilder();
    equals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder(null);
    equals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("null");
    equals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("{}");
    equals("{\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("{\"foo\":123}");
    equals("{\"foo\":123,\"webpush\":{\"notification\":{}}}", b.build());

    b = new FirebaseMpnBuilder("{\"webpush\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"data\":{\"KEY\":\"VAL\"}}}");
    equals("BODY", b.getBody());
    equals("TITLE", b.getTitle());
    strictSame(["KEY" => "VAL"], b.getData());
    equals("{\"webpush\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"data\":{\"KEY\":\"VAL\"}}}", b.build());
  }

  function testBuild() {
    b.setTitle("TITLE");
    b.setBody("BODY");
    equals("{\"webpush\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"}}}", b.build());

    b.setTitle(null);
    equals("{\"webpush\":{\"notification\":{\"body\":\"BODY\"}}}", b.build());
  }

  function testHeaders() {
    equals(null, b.getHeaders());

    b.setHeaders(["KEY" => "VAL"]);
    strictSame(["KEY" => "VAL"], b.getHeaders());
    equals("{\"webpush\":{\"notification\":{},\"headers\":{\"KEY\":\"VAL\"}}}", b.build());

    b.setHeaders(null);
    equals(null, b.getHeaders());
    equals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testTitle() {
    equals(null, b.getTitle());

    b.setTitle("VAL");
    equals("VAL", b.getTitle());
    equals("{\"webpush\":{\"notification\":{\"title\":\"VAL\"}}}", b.build());

    b.setTitle(null);
    equals(null, b.getTitle());
    equals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testBody() {
    equals(null, b.getBody());

    b.setBody("VAL");
    equals("VAL", b.getBody());
    equals("{\"webpush\":{\"notification\":{\"body\":\"VAL\"}}}", b.build());

    b.setBody(null);
    equals(null, b.getBody());
    equals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testIcon() {
    equals(null, b.getIcon());

    b.setIcon("VAL");
    equals("VAL", b.getIcon());
    equals("{\"webpush\":{\"notification\":{\"icon\":\"VAL\"}}}", b.build());

    b.setIcon(null);
    equals(null, b.getIcon());
    equals("{\"webpush\":{\"notification\":{}}}", b.build());
  }

  function testData() {
    equals(null, b.getData());

    b.setData(["KEY" => "VAL"]);
    strictSame(["KEY" => "VAL"], b.getData());
    equals("{\"webpush\":{\"notification\":{},\"data\":{\"KEY\":\"VAL\"}}}", b.build());

    b.setData(null);
    equals(null, b.getData());
    equals("{\"webpush\":{\"notification\":{}}}", b.build());
  }
}