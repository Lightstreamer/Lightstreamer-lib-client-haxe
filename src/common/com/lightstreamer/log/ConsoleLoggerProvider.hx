package com.lightstreamer.log;

import com.lightstreamer.client.Types;

@:expose("ConsoleLogLevel")
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

@:expose("ConsoleLoggerProvider")
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
class ConsoleLogger implements Logger {
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

  @:internal function log(level: String, line: String, ?exception: Exception) {
    var now = DateTools.format(Date.now(), "%Y.%m.%d %H:%M:%S");
    #if js
    var msg = '$now|$level|$category|$line';
    js.Browser.console.log(msg);
    if (exception != null) {
      js.Browser.console.log(exception);
    }
    #elseif java
    var msg = '$now|$level|$category|${java.lang.Thread.currentThread().getName()}|$line';
    Sys.println(msg);
    if (exception != null) {
      exception.printStackTrace();
    }
    #elseif cs
    var msg = '$now|$level|$category|${cs.system.threading.Thread.CurrentThread.ManagedThreadId}|$line';
    Sys.println(msg);
    if (exception != null) {
      Sys.println(exception.ToString());
    }
    #end
  }

  #if js
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
  #elseif (java || cs)
  public overload function fatal(line: String) {
    if (this.fatalEnabled) {
      log("FATAL", line);
    }
  }

  public overload function fatal(line: String, exception: Exception) {
    if (this.fatalEnabled) {
      log("FATAL", line, exception);
    }
  }

  public overload function error(line: String) {
    if (this.errorEnabled) {
      log("ERROR", line);
    }
  }

  public overload function error(line: String, exception: Exception) {
    if (this.errorEnabled) {
      log("ERROR", line, exception);
    }
  }

  public overload function warn(line: String) {
    if (this.warnEnabled) {
      log("WARN ", line);
    }
  }

  public overload function warn(line: String, exception: Exception) {
    if (this.warnEnabled) {
      log("WARN ", line, exception);
    }
  }

  public overload function info(line: String) {
    if (this.infoEnabled) {
      log("INFO ", line);
    }
  }

  public overload function info(line: String, exception: Exception) {
    if (this.infoEnabled) {
      log("INFO ", line, exception);
    }
  }

  public overload function debug(line: String) {
    if (this.debugEnabled) {
      log("DEBUG", line);
    }
  }

  public overload function debug(line: String, exception: Exception) {
    if (this.debugEnabled) {
      log("DEBUG", line, exception);
    }
  }
  #end

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