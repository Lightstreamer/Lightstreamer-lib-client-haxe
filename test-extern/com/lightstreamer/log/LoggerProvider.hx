package com.lightstreamer.log;

#if js @:native("LoggerProvider") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "LoggerProvider") #end
extern interface LoggerProvider {
  function getLogger(category: String): Logger;
}