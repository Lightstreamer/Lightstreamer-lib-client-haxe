package com.lightstreamer.log;

import com.lightstreamer.internal.NativeTypes;

class LSConsoleLogLevel {
  public static final TRACE = 0;
  public static final DEBUG = 10;
  public static final INFO = 20;
  public static final WARN = 30;
  public static final ERROR = 40;
  public static final FATAL = 50;

  function new() {}
}

class LSConsoleLoggerProvider implements LoggerProvider {
  final level: Int;

  public function new(level: Int) {
    this.level = level;
  }

  public function getLogger(category: String): Logger {
    return new ConsoleLogger(this.level, category);
  }
}

#if (java || cs || python) @:nativeGen #end
private class ConsoleLogger implements Logger {
  final level: Int;
  final category: String;
  final traceEnabled: Bool;
  final debugEnabled: Bool;
  final infoEnabled: Bool;
  final warnEnabled: Bool;
  final errorEnabled: Bool;
  final fatalEnabled: Bool;
  #if python
  static final logger = com.lightstreamer.internal.Logging.getLogger("lightstreamer");
  #end

  public function new(level: Int, category: String) {
    this.level = level;
    this.category = category;
    this.traceEnabled = level <= LSConsoleLogLevel.TRACE;
    this.debugEnabled = level <= LSConsoleLogLevel.DEBUG;
    this.infoEnabled  = level <= LSConsoleLogLevel.INFO;
    this.warnEnabled  = level <= LSConsoleLogLevel.WARN;
    this.errorEnabled = level <= LSConsoleLogLevel.ERROR;
    this.fatalEnabled = level <= LSConsoleLogLevel.FATAL;
  }

  inline function printLog(msg: String) {
    #if js
    js.Browser.console.log(msg);
    #elseif sys
    Sys.println(msg);
    #end
  }

  function format(level: String, line: String) {
    #if java
    var javaTime = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS"));
    var msg = '$javaTime|$level|$category|${java.lang.Thread.currentThread().getName()}|$line';
    #elseif cs
    var csTime = cs.system.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
    var msg = '$csTime|$level|$category|${cs.system.threading.Thread.CurrentThread.ManagedThreadId}|$line';
    #elseif python
    var pyTime = python.internal.UBuiltins.str(python.lib.datetime.Datetime.now());
    var pyThread = python.lib.Threading.current_thread().name;
    var msg = '$pyTime|$level|$category|$pyThread|$line';
    #else
    var now = Date.now().toString();
    var msg = '$now|$level|$category|$line';
    #end
    return msg;
  }

  inline function logFatal(msg: String) {
    #if python
    logger.critical(msg);
    #else
    printLog(msg);
    #end
  }

  inline function logError(msg: String) {
    #if python
    logger.error(msg);
    #else
    printLog(msg);
    #end
  }

  inline function logWarn(msg: String) {
    #if python
    logger.warning(msg);
    #else
    printLog(msg);
    #end
  }

  inline function logInfo(msg: String) {
    #if python
    logger.info(msg);
    #else
    printLog(msg);
    #end
  }

  inline function logDebug(msg: String) {
    #if python
    logger.debug(msg);
    #else
    printLog(msg);
    #end
  }

  inline function logTrace(msg: String) {
    #if python
    logger.debug(msg);
    #else
    printLog(msg);
    #end
  }

  public function fatal(line: String, ?exception: NativeException): Void {
    if (this.fatalEnabled) {
      logFatal(format("FATAL", line));
      if (exception != null) {
        logFatal(exception.details());
      }
    }
  }

  public function error(line: String, ?exception: NativeException): Void {
    if (this.errorEnabled) {
      logError(format("ERROR", line));
      if (exception != null) {
        logError(exception.details());
      }
    }
  }

  public function warn(line: String, ?exception: NativeException): Void {
    if (this.warnEnabled) {
      logWarn(format("WARN ", line));
      if (exception != null) {
        logWarn(exception.details());
      }
    }
  }

  public function info(line: String, ?exception: NativeException): Void {
    if (this.infoEnabled) {
      logInfo(format("INFO ", line));
      if (exception != null) {
        logInfo(exception.details());
      }
    }
  }

  public function debug(line: String, ?exception: NativeException): Void {
    if (this.debugEnabled) {
      logDebug(format("DEBUG", line));
      if (exception != null) {
        logDebug(exception.details());
      }
    }
  }

  public function trace(line: String, ?exception: NativeException): Void {
    if (this.traceEnabled) {
      logTrace(format("TRACE", line));
      if (exception != null) {
        logTrace(exception.details());
      }
    }
  }

  public function isFatalEnabled():Bool {
    return fatalEnabled;
  }

  public function isErrorEnabled():Bool {
    return errorEnabled;
  }

  public function isWarnEnabled():Bool {
    return warnEnabled;
  }

  public function isInfoEnabled():Bool {
    return infoEnabled;
  }

  public function isDebugEnabled():Bool {
    return debugEnabled;
  }

  public function isTraceEnabled():Bool {
    return traceEnabled;
  }
}