package com.lightstreamer.client;

import cpp.Star;

@:structAccess
@:include("Lightstreamer/ItemUpdate.h")
@:native("Lightstreamer::ItemUpdate")
extern class NativeItemUpdate {
  function new(hxobj: Star<cpp.Void>);
}