package com.lightstreamer.client.mpn;

import com.lightstreamer.client.mpn.MpnBuilder.LSMpnBuilder as MpnBuilder;
import com.lightstreamer.internal.NativeTypes.NativeList;

class TestMpnBuilderAndroid extends utest.Test {
  var b: MpnBuilder;

  function setup() {
    b = new MpnBuilder();
  }

  function testCtor() {
    b = new MpnBuilder();
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());

    b = new MpnBuilder(null);
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());

    b = new MpnBuilder("null");
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());

    b = new MpnBuilder("{}");
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());

    b = new MpnBuilder("{\"foo\":123}");
    jsonEquals("{\"foo\":123,\"android\":{\"notification\":{}}}", b.build());

    b = new MpnBuilder("{\"android\":{\"notification\":{\"title\":\"TITLE\",\"title_loc_args\":[\"ARG\"],\"body\":\"BODY\"},\"priority\":\"1\",\"data\":{\"KEY\":\"VAL\"}}}");
    equals("BODY", b.body());
    equals("TITLE", b.title());
    equals("1", b.priority());
    strictSame(["KEY" => "VAL"], b.data());
    strictSame(["ARG"], b.titleLocArguments().toHaxe());
    jsonEquals("{\"android\":{\"notification\":{\"title_loc_args\":[\"ARG\"],\"title\":\"TITLE\",\"body\":\"BODY\"},\"data\":{\"KEY\":\"VAL\"},\"priority\":\"1\"}}", b.build());
  }

  function testBuild() {
    b.priority("1");
    b.title("TITLE");
    b.body("BODY");
    jsonEquals("{\"android\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"},\"priority\":\"1\"}}", b.build());

    b.priority(null);
    jsonEquals("{\"android\":{\"notification\":{\"title\":\"TITLE\",\"body\":\"BODY\"}}}", b.build());
  }

  function testCollapseKey() {
    equals(null, b.collapseKey());
    
    b.collapseKey("VAL");
    equals("VAL", b.collapseKey());
    jsonEquals("{\"android\":{\"notification\":{},\"collapse_key\":\"VAL\"}}", b.build());
    
    b.collapseKey(null);
    equals(null, b.collapseKey());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testPriority() {
    equals(null, b.priority());
    
    b.priority("VAL");
    equals("VAL", b.priority());
    jsonEquals("{\"android\":{\"notification\":{},\"priority\":\"VAL\"}}", b.build());
    
    b.priority(null);
    equals(null, b.priority());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testTimeToLive() {
    equals(null, b.timeToLiveAsString());
    equals(null, b.timeToLiveAsInteger());

    b.timeToLive("TTL");
    equals("TTL", b.timeToLiveAsString());
    equals(null, b.timeToLiveAsInteger());
    jsonEquals("{\"android\":{\"notification\":{},\"ttl\":\"TTL\"}}", b.build());

    b.timeToLive(123);
    equals("123", b.timeToLiveAsString());
    equals(123, b.timeToLiveAsInteger());
    jsonEquals("{\"android\":{\"notification\":{},\"ttl\":\"123\"}}", b.build());

    b.timeToLive((null:String));
    equals(null, b.timeToLiveAsString());
    equals(null, b.timeToLiveAsInteger());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testTitle() {
    equals(null, b.title());
    
    b.title("VAL");
    equals("VAL", b.title());
    jsonEquals("{\"android\":{\"notification\":{\"title\":\"VAL\"}}}", b.build());
    
    b.title(null);
    equals(null, b.title());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testTitleLocKey() {
    equals(null, b.titleLocKey());
    
    b.titleLocKey("VAL");
    equals("VAL", b.titleLocKey());
    jsonEquals("{\"android\":{\"notification\":{\"title_loc_key\":\"VAL\"}}}", b.build());
    
    b.titleLocKey(null);
    equals(null, b.titleLocKey());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testTitleLocArguments() {
    equals(null, b.titleLocArguments());
    
    b.titleLocArguments(new NativeList(["VAL"]));
    strictSame(["VAL"], b.titleLocArguments().toHaxe());
    jsonEquals("{\"android\":{\"notification\":{\"title_loc_args\":[\"VAL\"]}}}", b.build());
    
    b.titleLocArguments(null);
    equals(null, b.titleLocArguments());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testBody() {
    equals(null, b.body());
    
    b.body("VAL");
    equals("VAL", b.body());
    jsonEquals("{\"android\":{\"notification\":{\"body\":\"VAL\"}}}", b.build());
    
    b.body(null);
    equals(null, b.body());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testBodyLocKey() {
    equals(null, b.bodyLocKey());
    
    b.bodyLocKey("VAL");
    equals("VAL", b.bodyLocKey());
    jsonEquals("{\"android\":{\"notification\":{\"body_loc_key\":\"VAL\"}}}", b.build());
    
    b.bodyLocKey(null);
    equals(null, b.bodyLocKey());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testBodyLocArguments() {
    equals(null, b.bodyLocArguments());
    
    b.bodyLocArguments(new NativeList(["VAL"]));
    strictSame(["VAL"], b.bodyLocArguments().toHaxe());
    jsonEquals("{\"android\":{\"notification\":{\"body_loc_args\":[\"VAL\"]}}}", b.build());
    
    b.bodyLocArguments(null);
    equals(null, b.bodyLocArguments());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testIcon() {
    equals(null, b.icon());
    
    b.icon("VAL");
    equals("VAL", b.icon());
    jsonEquals("{\"android\":{\"notification\":{\"icon\":\"VAL\"}}}", b.build());
    
    b.icon(null);
    equals(null, b.icon());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testSound() {
    equals(null, b.sound());
    
    b.sound("VAL");
    equals("VAL", b.sound());
    jsonEquals("{\"android\":{\"notification\":{\"sound\":\"VAL\"}}}", b.build());
    
    b.sound(null);
    equals(null, b.sound());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testTag() {
    equals(null, b.tag());
    
    b.tag("VAL");
    equals("VAL", b.tag());
    jsonEquals("{\"android\":{\"notification\":{\"tag\":\"VAL\"}}}", b.build());
    
    b.tag(null);
    equals(null, b.tag());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testColor() {
    equals(null, b.color());
    
    b.color("VAL");
    equals("VAL", b.color());
    jsonEquals("{\"android\":{\"notification\":{\"color\":\"VAL\"}}}", b.build());
    
    b.color(null);
    equals(null, b.color());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testClickAction() {
    equals(null, b.clickAction());
    
    b.clickAction("VAL");
    equals("VAL", b.clickAction());
    jsonEquals("{\"android\":{\"notification\":{\"click_action\":\"VAL\"}}}", b.build());
    
    b.clickAction(null);
    equals(null, b.clickAction());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }

  function testData() {
    equals(null, b.data());
    
    b.data(["KEY" => "VAL"]);
    strictSame(["KEY" => "VAL"], b.data());
    jsonEquals("{\"android\":{\"notification\":{},\"data\":{\"KEY\":\"VAL\"}}}", b.build());
    
    b.data(null);
    equals(null, b.data());
    jsonEquals("{\"android\":{\"notification\":{}}}", b.build());
  }
}