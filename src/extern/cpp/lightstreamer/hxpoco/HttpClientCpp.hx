package lightstreamer.hxpoco;

import cpp.ConstCharStar;

@:structAccess
@:include("HxPoco.h")
@:native("Lightstreamer::HxPoco::HttpClientCpp")
extern class HttpClientCpp {
  function new(host: ConstCharStar, body: ConstCharStar);
  function start(): Void;
  function dispose(): Void;
  function submit(): Void;
  function run(): Void;
  function isDisposed(): Bool;
  function onText(line: ConstCharStar): Void;
  function onError(msg: ConstCharStar): Void;
  function onDone(): Void;
}