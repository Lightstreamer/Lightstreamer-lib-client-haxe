package com.lightstreamer.log;

#if python
#if LS_TEST
@:pythonImport("ls_python_client_api", "LoggerProvider")
#else
@:pythonImport(".ls_python_client_api", "LoggerProvider")
#end
#end
extern interface LoggerProvider {
  function getLogger(category: String): Logger;
}