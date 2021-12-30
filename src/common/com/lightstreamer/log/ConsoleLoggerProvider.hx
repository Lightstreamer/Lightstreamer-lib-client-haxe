package com.lightstreamer.log;

import com.lightstreamer.client.Types;

#if (js || python) @:expose @:native("ConsoleLogLevel") #end
@:nativeGen
class ConsoleLogLevel {
  public static final TRACE = 0;
  public static final DEBUG = 10;
  public static final INFO = 20;
  public static final WARN = 30;
  public static final ERROR = 40;
  public static final FATAL = 50;

  @:internal function new() {}
}

#if (js || python) @:expose @:native("ConsoleLoggerProvider") #end
@:nativeGen
class ConsoleLoggerProvider implements LoggerProvider {
  @:internal final level: Int;

  public function new(level: Int) {
    this.level = level;
  }

  public function getLogger(category: String): Logger {
    return new ConsoleLogger(this.level, category);
  }
}

@:nativeGen
private class ConsoleLogger implements Logger {
  @:internal final level: Int;
  @:internal final category: String;
  @:internal final traceEnabled: Bool;
  @:internal final debugEnabled: Bool;
  @:internal final infoEnabled: Bool;
  @:internal final warnEnabled: Bool;
  @:internal final errorEnabled: Bool;
  @:internal final fatalEnabled: Bool;

  public function new(level: Int, category: String) {
    this.level = level;
    this.category = category;
    this.traceEnabled = level <= ConsoleLogLevel.TRACE;
    this.debugEnabled = level <= ConsoleLogLevel.DEBUG;
    this.infoEnabled  = level <= ConsoleLogLevel.INFO;
    this.warnEnabled  = level <= ConsoleLogLevel.WARN;
    this.errorEnabled = level <= ConsoleLogLevel.ERROR;
    this.fatalEnabled = level <= ConsoleLogLevel.FATAL;
  }

  @:internal inline function printLog(msg: String) {
    #if js
    js.Browser.console.log(msg);
    #elseif sys
    Sys.println(msg);
    #end
  }

  @:access(haxe.Exception.caught)
  @:internal function log(level: String, line: String, ?exception: Exception) {
    var now = DateTools.format(Date.now(), "%Y.%m.%d %H:%M:%S");
    #if java
    var msg = '$now|$level|$category|${java.lang.Thread.currentThread().getName()}|$line';
    #elseif cs
    var msg = '$now|$level|$category|${cs.system.threading.Thread.CurrentThread.ManagedThreadId}|$line';
    #else
    var msg = '$now|$level|$category|$line';
    #end
    printLog(msg);
    if (exception != null) {
      printLog(exception.details());
    }
  }

  public function fatal(line: String, ?exception: Exception): Void {
    if (this.fatalEnabled) {
      log("FATAL", line, exception);
    }
  }

  public function error(line: String, ?exception: Exception): Void {
    if (this.errorEnabled) {
      log("ERROR", line, exception);
    }
  }

  public function warn(line: String, ?exception: Exception): Void {
    if (this.warnEnabled) {
      log("WARN ", line, exception);
    }
  }

  public function info(line: String, ?exception: Exception): Void {
    if (this.infoEnabled) {
      log("INFO ", line, exception);
    }
  }

  public function debug(line: String, ?exception: Exception): Void {
    if (this.debugEnabled) {
      log("DEBUG", line, exception);
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
}