package com.lightstreamer.log;

@:nativeGen
interface LoggerProvider {
  function getLogger(category: String): Logger;
}