package com.lightstreamer.log;

/**
 Logging level.
 */
public class ConsoleLogLevel {

  private ConsoleLogLevel() {}

  /**
    Trace logging level.
   
    This level enables all logging.
   */
  public static final int TRACE = com.lightstreamer.log.internal.ConsoleLogLevel.TRACE;
  /**
    Debug logging level.
     
    This level enables all logging except tracing.
   */
  public static final int DEBUG = com.lightstreamer.log.internal.ConsoleLogLevel.DEBUG;
  /**
    Info logging level.
     
    This level enables logging for information, warnings, errors and fatal errors.
   */
  public static final int INFO = com.lightstreamer.log.internal.ConsoleLogLevel.INFO;
  /**
    Warn logging level.
     
    This level enables logging for warnings, errors and fatal errors.
   */
  public static final int WARN = com.lightstreamer.log.internal.ConsoleLogLevel.WARN;
  /**
    Error logging level.
     
    This level enables logging for errors and fatal errors.
   */
  public static final int ERROR = com.lightstreamer.log.internal.ConsoleLogLevel.ERROR;
  /**
    Fatal logging level.
     
    This level enables logging for fatal errors only.
   */
  public static final int FATAL = com.lightstreamer.log.internal.ConsoleLogLevel.FATAL;
}
