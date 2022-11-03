package com.lightstreamer.log;

#if (java || cs || python) @:nativeGen #end
extern interface LoggerProvider {
  function getLogger(category: String): Logger;
}