package com.lightstreamer.log;

import cpp.Star;
import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:native("Lightstreamer::LoggerProvider")
@:include("Lightstreamer/LoggerProvider.h")
extern class NativeLoggerProvider {
  function getLogger(category: Reference<CppString>): Star<NativeLogger>;
}