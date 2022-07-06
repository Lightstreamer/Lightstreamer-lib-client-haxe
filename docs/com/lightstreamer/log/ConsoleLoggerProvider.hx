package com.lightstreamer.log;

/**
 Logging level.
 */
class ConsoleLogLevel {
  /**
    Trace logging level.
   
    This level enables all logging.
   */
  public static final TRACE = 0;
  /**
    Debug logging level.
     
    This level enables all logging except tracing.
   */
  public static final DEBUG = 10;
  /**
    Info logging level.
     
    This level enables logging for information, warnings, errors and fatal errors.
   */
  public static final INFO = 20;
  /**
    Warn logging level.
     
    This level enables logging for warnings, errors and fatal errors.
   */
  public static final WARN = 30;
  /**
    Error logging level.
     
    This level enables logging for errors and fatal errors.
   */
  public static final ERROR = 40;
  /**
    Fatal logging level.
     
    This level enables logging for fatal errors only.
   */
  public static final FATAL = 50;
}

/**
  Simple concrete logging provider that logs on the system console.
 
  To be used, an instance of this class has to be passed to the library through the `LightstreamerClient.setLoggerProvider`.
 */
class ConsoleLoggerProvider implements LoggerProvider {
  /**
    Creates an instace of the concrete system console logger.
     
    @param level The desired logging level. See `ConsoleLogLevel`.
  */
  public function new(level: Int) {}
  public function getLogger(category: String): Logger return null;
}