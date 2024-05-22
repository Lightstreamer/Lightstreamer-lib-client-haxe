package com.lightstreamer.log;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:native("Lightstreamer::Logger")
@:include("Lightstreamer/Logger.h")
extern class NativeLogger {
  function error(line: Reference<CppString>): Void;
  function warn(line: Reference<CppString>): Void;
  function info(line: Reference<CppString>): Void;
  function debug(line: Reference<CppString>): Void;
  function trace(line: Reference<CppString>): Void;
  function fatal(line: Reference<CppString>): Void;
  function isTraceEnabled(): Bool;
  function isDebugEnabled(): Bool;
  function isInfoEnabled(): Bool;
  function isWarnEnabled(): Bool;
  function isErrorEnabled(): Bool;
  function isFatalEnabled(): Bool;
}