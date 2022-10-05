package com.lightstreamer.internal;

import python.KwArgs;
import python.lib.io.IOBase;

@:pythonImport("logging")
extern class Logging {
  static final CRITICAL: Int;
  static final ERROR: Int;
  static final WARNING: Int;
  static final INFO: Int;
  static final DEBUG: Int;
  static function basicConfig(kwargs: KwArgs<{?level: Int, ?format: String, stream: IOBase}>): Void;
  static function getLogger(name: String): Logger;
}

@:pythonImport("logging", Logger)
extern class Logger {
  function debug(msg: String): Void;
  function info(msg: String): Void;
  function warning(msg: String): Void;
  function error(msg: String): Void;
  function critical(msg: String): Void;
}