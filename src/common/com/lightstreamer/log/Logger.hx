package com.lightstreamer.log;

import com.lightstreamer.internal.NativeTypes;

#if (java || cs || python) @:nativeGen #end
interface Logger {
  function fatal(line: String, ?exception: NativeException): Void;
  function error(line: String, ?exception: NativeException): Void;
  function warn(line: String, ?exception: NativeException): Void;
  function info(line: String, ?exception: NativeException): Void;
  function debug(line: String, ?exception: NativeException): Void;
  function trace(line: String, ?exception: NativeException): Void;
  function isFatalEnabled(): Bool;
  function isErrorEnabled(): Bool;
  function isWarnEnabled(): Bool;
  function isInfoEnabled(): Bool;
  function isDebugEnabled(): Bool;
  function isTraceEnabled(): Bool;
}