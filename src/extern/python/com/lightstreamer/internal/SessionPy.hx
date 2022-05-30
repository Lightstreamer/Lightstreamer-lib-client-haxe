package com.lightstreamer.internal;

@:pythonImport("com_lightstreamer", "SessionPy")
extern class SessionPy {
  static function getInstance(): Any;
  static function freeInstance(): Any;
}