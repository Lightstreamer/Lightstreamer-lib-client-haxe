package com.lightstreamer.log;

import com.lightstreamer.internal.NativeTypes.NativeException;

abstract class AbstractLogger implements Logger {
  #if cs
  abstract function isFatalEnabled(): Bool;
  abstract function isErrorEnabled(): Bool;
  abstract function isWarnEnabled(): Bool;
  abstract function isInfoEnabled(): Bool;
  abstract function isDebugEnabled(): Bool;
  abstract function isTraceEnabled(): Bool;

  abstract function fatal(line: String, ?exception: NativeException): Void;
  abstract function error(line: String, ?exception: NativeException): Void;
  abstract function warn(line: String, ?exception: NativeException): Void;
  abstract function info(line: String, ?exception: NativeException): Void;
  abstract function debug(line: String, ?exception: NativeException): Void;
  abstract function trace(line: String, ?exception: NativeException): Void;

  inline public function Fatal(line: String, ?exception: NativeException) fatal(line, exception);
  inline public function Error(line: String, ?exception: NativeException) error(line, exception);
  inline public function Warn(line: String, ?exception: NativeException) warn(line, exception);
  inline public function Info(line: String, ?exception: NativeException) info(line, exception);
  inline public function Debug(line: String, ?exception: NativeException) debug(line, exception);
  inline public function Trace(line: String, ?exception: NativeException) this.trace(line, exception);

  @:property public var IsFatalEnabled(get, never): Bool;
  @:property public var IsErrorEnabled(get, never): Bool;
  @:property public var IsWarnEnabled(get, never): Bool;
  @:property public var IsInfoEnabled(get, never): Bool;
  @:property public var IsDebugEnabled(get, never): Bool;
  @:property public var IsTraceEnabled(get, never): Bool;

  inline function get_IsFatalEnabled() return isFatalEnabled();
  inline function get_IsErrorEnabled() return isErrorEnabled();
  inline function get_IsWarnEnabled() return isWarnEnabled();
  inline function get_IsInfoEnabled() return isInfoEnabled();
  inline function get_IsDebugEnabled() return isDebugEnabled();
  inline function get_IsTraceEnabled() return isTraceEnabled();
  #end
}