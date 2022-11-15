package com.lightstreamer.internal;

@:build(com.lightstreamer.internal.Macros.buildPythonImport("com_lightstreamer_net", "SessionPy"))
extern class SessionPy {
  static function getInstance(): Any;
  static function freeInstance(): Any;
}