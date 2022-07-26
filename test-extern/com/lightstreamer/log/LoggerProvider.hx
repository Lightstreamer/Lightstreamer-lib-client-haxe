package com.lightstreamer.log;

#if js @:native("LoggerProvider") #end
extern interface LoggerProvider {
  function getLogger(category: String): Logger;
}