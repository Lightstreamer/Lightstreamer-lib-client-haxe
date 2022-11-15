package com.lightstreamer.log;

@:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "LoggerProvider"))
extern interface LoggerProvider {
  function getLogger(category: String): Logger;
}