package com.lightstreamer.log;

import com.lightstreamer.internal.NativeTypes;

#if !cs
@:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "Logger"))
extern interface Logger {
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
#else
@:using(Logger.LoggerExtender)
@:native("com.lightstreamer.log.ILogger")
extern interface Logger {
  function Fatal(line: String, ?exception: NativeException): Void;
  function Error(line: String, ?exception: NativeException): Void;
  function Warn(line: String, ?exception: NativeException): Void;
  function Info(line: String, ?exception: NativeException): Void;
  function Debug(line: String, ?exception: NativeException): Void;
  function Trace(line: String, ?exception: NativeException): Void;
  var IsFatalEnabled(get, never): Bool;
  var IsErrorEnabled(get, never): Bool;
  var IsWarnEnabled(get, never): Bool;
  var IsInfoEnabled(get, never): Bool;
  var IsDebugEnabled(get, never): Bool;
  var IsTraceEnabled(get, never): Bool;
}

@:publicFields
class LoggerExtender {
  inline static function fatal(logger: Logger, line: String, ?exception: NativeException) logger.Fatal(line, exception);
  inline static function error(logger: Logger, line: String, ?exception: NativeException) logger.Error(line, exception);
  inline static function warn(logger: Logger, line: String, ?exception: NativeException) logger.Warn(line, exception);
  inline static function info(logger: Logger, line: String, ?exception: NativeException) logger.Info(line, exception);
  inline static function debug(logger: Logger, line: String, ?exception: NativeException) logger.Debug(line, exception);
  inline static function trace(logger: Logger, line: String, ?exception: NativeException) logger.Trace(line, exception);
  inline static function isFatalEnabled(logger: Logger) return logger.IsFatalEnabled;
  inline static function isErrorEnabled(logger: Logger) return logger.IsErrorEnabled;
  inline static function isWarnEnabled(logger: Logger) return logger.IsWarnEnabled;
  inline static function isInfoEnabled(logger: Logger) return logger.IsInfoEnabled;
  inline static function isDebugEnabled(logger: Logger) return logger.IsDebugEnabled;
  inline static function isTraceEnabled(logger: Logger) return logger.IsTraceEnabled;
}
#end