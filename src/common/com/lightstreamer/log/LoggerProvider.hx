package com.lightstreamer.log;

#if (java || cs || python) @:nativeGen #end
interface LoggerProvider {
  function getLogger(category: String): Logger;
}