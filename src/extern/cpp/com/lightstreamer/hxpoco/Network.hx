package com.lightstreamer.hxpoco;

import poco.net.Context.ContextPtr;

@:structAccess
@:include("Lightstreamer/HxPoco/Network.h")
@:native("Lightstreamer::HxPoco::Network")
extern class Network {
  static function setSSLContext(ctx: ContextPtr): Void;
  static function clearSSLContext(): Void;
  static final _cookieJar: CookieJar;
}