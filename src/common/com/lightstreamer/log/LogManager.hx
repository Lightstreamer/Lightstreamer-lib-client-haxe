/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.log;

import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.RLock;

@:unreflective
class LogManager {
  static final lock = new RLock();
  static final logInstances: Map<String, LoggerProxy> = [];
  static final emptyLogger = new EmptyLogger();
  static var currentLoggerProvider: Null<LoggerProvider>;

  public static function getLogger(category: String): Logger {
    return lock.synchronized(() -> {
      var log = logInstances[category];
      if (log == null) {
        log = logInstances[category] = new LoggerProxy(newLogger(category));
      }
      return (log : LoggerProxy);
    });
  }

  public static function setLoggerProvider(provider: Null<LoggerProvider>): Void {
    lock.synchronized(() -> {
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

private class EmptyLogger extends AbstractLogger {
  inline public function new() {}
  inline public function fatal(line: String, ?exception: NativeException) {}
	inline public function error(line: String, ?exception: NativeException) {}
	inline public function warn(line: String, ?exception: NativeException) {}
	inline public function info(line: String, ?exception: NativeException) {}
	inline public function debug(line: String, ?exception: NativeException) {}
	inline public function trace(line: String, ?exception: NativeException) {}
  inline public function isFatalEnabled(): Bool return false;
  inline public function isErrorEnabled(): Bool return false;
  inline public function isWarnEnabled(): Bool return false;
  inline public function isInfoEnabled(): Bool return false;
  inline public function isDebugEnabled(): Bool return false;
  inline public function isTraceEnabled(): Bool return false;
}

private class LoggerProxy extends AbstractLogger {
  public var wrappedLogger(null, default): Logger;

  inline public function new(logger: Logger) {
    this.wrappedLogger = logger;
  }
  inline public function fatal(line: String, ?exception: NativeException) {
    this.wrappedLogger.fatal(line, exception);
  }
	inline public function error(line: String, ?exception: NativeException) {
    this.wrappedLogger.error(line, exception);
  }
	inline public function warn(line: String, ?exception: NativeException) {
    this.wrappedLogger.warn(line, exception);
  }
	inline public function info(line: String, ?exception: NativeException) {
    this.wrappedLogger.info(line, exception);
  }
	inline public function debug(line: String, ?exception: NativeException) {
    this.wrappedLogger.debug(line, exception);
  }
  inline public function trace(line: String, ?exception: NativeException) {
    this.wrappedLogger.trace(line, exception);
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
  inline public function isTraceEnabled(): Bool {
    return this.wrappedLogger.isTraceEnabled();
  }
}