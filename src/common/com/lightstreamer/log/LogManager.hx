package com.lightstreamer.log;

import com.lightstreamer.client.Types.Exception;
import hx.concurrent.lock.RLock;

class LogManager {
  static final lock = new RLock();
  static final logInstances: Map<String, Logger> = [];
  static final emptyLogger = new EmptyLogger();
  static var currentLoggerProvider: LoggerProvider;

  public static function getLogger(category: String): Logger {
    return lock.execute(() -> {
      var log = logInstances[category];
      if (log == null) {
        log = logInstances[category] = newLogger(category);
      }
      return log;
    });
  }

  public static function setLogger(provider: LoggerProvider): Void {
    lock.execute(() -> {
      currentLoggerProvider = provider;
      for (category in logInstances.keys()) {
        logInstances[category] = newLogger(category);
      }
    });
  }

  static inline function newLogger(category) {
    return currentLoggerProvider == null ? emptyLogger : currentLoggerProvider.getLogger(category);
  }
}

class EmptyLogger implements Logger {

  public function new() {}
  
  #if js
  public function fatal(line: String, ?exception: Exception) {}
	public function error(line: String, ?exception: Exception) {}
	public function warn(line: String, ?exception: Exception) {}
	public function info(line: String, ?exception: Exception) {}
	public function debug(line: String, ?exception: Exception) {}
  #elseif (java || cs)
  public overload function fatal(line: String) {}
  public overload function fatal(line: String, exception: Exception) {}
  public overload function error(line: String) {}
  public overload function error(line: String, exception: Exception) {}
  public overload function warn(line: String) {}
  public overload function warn(line: String, exception: Exception) {}
  public overload function info(line: String) {}
  public overload function info(line: String, exception: Exception) {}
  public overload function debug(line: String) {}
  public overload function debug(line: String, exception: Exception) {}
  #end

  public function isFatalEnabled(): Bool {
    return false;
  }
  public function isErrorEnabled(): Bool {
    return false;
  }
  public function isWarnEnabled(): Bool {
    return false;
  }
  public function isInfoEnabled(): Bool {
    return false;
  }
  public function isDebugEnabled(): Bool {
    return false;
  }
}