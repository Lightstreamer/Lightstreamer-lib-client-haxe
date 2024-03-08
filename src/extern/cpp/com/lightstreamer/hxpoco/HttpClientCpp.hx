package com.lightstreamer.hxpoco;

import cpp.ConstCharStar;
import poco.net.Context.ContextPtr;
import com.lightstreamer.cpp.CppStringMap;

@:structAccess
@:include("HxPoco.h")
@:native("Lightstreamer::HxPoco::HttpClientCpp")
extern class HttpClientCpp {
  // public
  static function setSSLContext(ctx: ContextPtr): Void;
  function new(host: ConstCharStar, body: ConstCharStar, headers: CppStringMap);
  function start(): Void;
  function dispose(): Void;
  function isDisposed(): Bool;
  // protected
  function submit(): Void;
  function run(): Void;
  function onText(line: ConstCharStar): Void;
  function onError(msg: ConstCharStar): Void;
  function onDone(): Void;
}