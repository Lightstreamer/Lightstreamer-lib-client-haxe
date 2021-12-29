package com.lightstreamer.log;

import com.lightstreamer.client.Types;

@:nativeGen
interface Logger {
  #if js
  function fatal(line: String, ?exception: Exception): Void;
  function error(line: String, ?exception: Exception): Void;
  function warn(line: String, ?exception: Exception): Void;
  function info(line: String, ?exception: Exception): Void;
  function debug(line: String, ?exception: Exception): Void;
  #elseif (java || cs)
  overload function fatal(line: String): Void;
  overload function fatal(line: String, exception: Exception): Void;
  overload function error(line: String): Void;
  overload function error(line: String, exception: Exception): Void;
  overload function warn(line: String): Void;
  overload function warn(line: String, exception: Exception): Void;
  overload function info(line: String): Void;
  overload function info(line: String, exception: Exception): Void;
  overload function debug(line: String): Void;
  overload function debug(line: String, exception: Exception): Void;
  #end
  function isFatalEnabled(): Bool;
  function isErrorEnabled(): Bool;
  function isWarnEnabled(): Bool;
  function isInfoEnabled(): Bool;
  function isDebugEnabled(): Bool;
}