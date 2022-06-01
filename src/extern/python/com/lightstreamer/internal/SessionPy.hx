package com.lightstreamer.internal;

@:pythonImport("com_lightstreamer_net", "SessionPy")
extern class SessionPy {
  static function getInstance(): Any;
  static function freeInstance(): Any;
}