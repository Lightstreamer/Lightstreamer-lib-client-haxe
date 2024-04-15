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
  /** 
   * **NB** may block
   */
  function dispose(): Void;
  // protected
  function gc_enter_blocking(): Void;
  function gc_exit_blocking(): Void;
  function submit(): Void;
  function doSubmit(): Void;
  function onText(line: ConstCharStar): Void;
  function onError(msg: ConstCharStar): Void;
  function onDone(): Void;
}