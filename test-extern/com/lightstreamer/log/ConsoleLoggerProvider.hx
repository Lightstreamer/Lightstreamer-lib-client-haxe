package com.lightstreamer.log;

#if python
@:pythonImport("lightstreamer_client", "ConsoleLogLevel")
#end
#if js @:native("ConsoleLogLevel") #end
extern class ConsoleLogLevel {
  public static final TRACE: Int;
  public static final DEBUG: Int;
  public static final INFO: Int;
  public static final WARN: Int;
  public static final ERROR: Int;
  public static final FATAL: Int;
}

#if python
@:pythonImport("lightstreamer_client", "ConsoleLoggerProvider")
#end
#if js @:native("ConsoleLoggerProvider") #end
extern class ConsoleLoggerProvider implements LoggerProvider {
  public function new(level: Int);
  public function getLogger(category: String): Logger;
}