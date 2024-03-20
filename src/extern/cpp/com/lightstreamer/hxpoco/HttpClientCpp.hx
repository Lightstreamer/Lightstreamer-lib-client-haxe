package com.lightstreamer.hxpoco;

import cpp.Reference;
import cpp.ConstCharStar;
import poco.net.ProxyConfig;
import com.lightstreamer.cpp.CppStringMap;

@:structAccess
@:include("Lightstreamer/HxPoco/HttpClient.h")
@:native("Lightstreamer::HxPoco::HttpClient")
extern class HttpClientCpp {
  // public
  function new(host: ConstCharStar, body: ConstCharStar, headers: CppStringMap, proxy: Reference<ProxyConfig>);
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