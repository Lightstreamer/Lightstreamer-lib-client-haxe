package com.lightstreamer.log;

import com.lightstreamer.client.NativeTypes;
import hx.concurrent.lock.RLock;

class LogManager {
  static final lock = new RLock();
  static final logInstances: Map<String, LoggerProxy> = [];
  static final emptyLogger = new EmptyLogger();
  static var currentLoggerProvider: Null<LoggerProvider>;

  public static function getLogger(category: String): Logger {
    return lock.execute(() -> {
      var log = logInstances[category];
      if (log == null) {
        log = logInstances[category] = new LoggerProxy(newLogger(category));
      }
      return (log : LoggerProxy);
    });
  }

  public static function setLoggerProvider(provider: LoggerProvider): Void {
    lock.execute(() -> {
      currentLoggerProvider = provider;
      for (category => proxy in logInstances) {
        proxy.wrappedLogger = newLogger(category);
      }
    });
  }

  static inline function newLogger(category) {
    return currentLoggerProvider == null ? emptyLogger : currentLoggerProvider.getLogger(category);
  }
}

private class EmptyLogger implements Logger {
  inline public function new() {}
  inline public function fatal(line: String, ?exception: Exception) {}
	inline public function error(line: String, ?exception: Exception) {}
	inline public function warn(line: String, ?exception: Exception) {}
	inline public function info(line: String, ?exception: Exception) {}
	inline public function debug(line: String, ?exception: Exception) {}
  inline public function isFatalEnabled(): Bool return false;
  inline public function isErrorEnabled(): Bool return false;
  inline public function isWarnEnabled(): Bool return false;
  inline public function isInfoEnabled(): Bool return false;
  inline public function isDebugEnabled(): Bool return false;
}

private class LoggerProxy implements Logger {
  public var wrappedLogger(null, default): Logger;

  inline public function new(logger: Logger) {
    this.wrappedLogger = logger;
  }
  inline public function fatal(line: String, ?exception: Exception) {
    this.wrappedLogger.fatal(line, exception);
  }
	inline public function error(line: String, ?exception: Exception) {
    this.wrappedLogger.error(line, exception);
  }
	inline public function warn(line: String, ?exception: Exception) {
    this.wrappedLogger.warn(line, exception);
  }
	inline public function info(line: String, ?exception: Exception) {
    this.wrappedLogger.info(line, exception);
  }
	inline public function debug(line: String, ?exception: Exception) {
    this.wrappedLogger.debug(line, exception);
  }
  inline public function isFatalEnabled(): Bool {
    return this.wrappedLogger.isFatalEnabled();
  }
  inline public function isErrorEnabled(): Bool {
    return this.wrappedLogger.isErrorEnabled();
  }
  inline public function isWarnEnabled(): Bool {
    return this.wrappedLogger.isWarnEnabled();
  }
  inline public function isInfoEnabled(): Bool {
    return this.wrappedLogger.isInfoEnabled();
  }
  inline public function isDebugEnabled(): Bool {
    return this.wrappedLogger.isDebugEnabled();
  }
}