package com.lightstreamer.internal;

#if LS_TEST
@:pythonImport("com_lightstreamer_net", "SessionPy")
#else
@:pythonImport(".com_lightstreamer_net", "SessionPy")
#end
extern class SessionPy {
  static function getInstance(): Any;
  static function freeInstance(): Any;
}