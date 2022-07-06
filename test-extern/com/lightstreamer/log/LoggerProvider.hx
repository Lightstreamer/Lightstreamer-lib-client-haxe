package com.lightstreamer.log;

extern interface LoggerProvider {
  function getLogger(category: String): Logger;
}