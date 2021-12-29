package com.lightstreamer.log;

import com.lightstreamer.client.Types;

@:nativeGen
interface Logger {
  function fatal(line: String, ?exception: Exception): Void;
  function error(line: String, ?exception: Exception): Void;
  function warn(line: String, ?exception: Exception): Void;
  function info(line: String, ?exception: Exception): Void;
  function debug(line: String, ?exception: Exception): Void;
  function isFatalEnabled(): Bool;
  function isErrorEnabled(): Bool;
  function isWarnEnabled(): Bool;
  function isInfoEnabled(): Bool;
  function isDebugEnabled(): Bool;
}