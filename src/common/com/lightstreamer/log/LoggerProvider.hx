package com.lightstreamer.log;

#if js @:native("LoggerProvider") #end
@:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "LoggerProvider"))
#if cs @:native("com.lightstreamer.log.ILoggerProvider") #end
extern interface LoggerProvider {
  #if cs @:native("GetLogger") #end
  function getLogger(category: String): Logger;
}