package com.lightstreamer.log;

import com.lightstreamer.internal.NativeTypes;

#if python
#if LS_TEST
@:pythonImport("ls_python_client_api", "Logger")
#else
@:pythonImport(".ls_python_client_api", "Logger")
#end
#end
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