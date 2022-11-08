package com.lightstreamer.log;

import com.lightstreamer.log.LSConsoleLogLevel;

/**
 Logging level.
 */
public class ConsoleLogLevel {

  private ConsoleLogLevel() {}

  /**
    Trace logging level.
   
    This level enables all logging.
   */
  public static final int TRACE = LSConsoleLogLevel.TRACE;
  /**
    Debug logging level.
     
    This level enables all logging except tracing.
   */
  public static final int DEBUG = LSConsoleLogLevel.DEBUG;
  /**
    Info logging level.
     
    This level enables logging for information, warnings, errors and fatal errors.
   */
  public static final int INFO = LSConsoleLogLevel.INFO;
  /**
    Warn logging level.
     
    This level enables logging for warnings, errors and fatal errors.
   */
  public static final int WARN = LSConsoleLogLevel.WARN;
  /**
    Error logging level.
     
    This level enables logging for errors and fatal errors.
   */
  public static final int ERROR = LSConsoleLogLevel.ERROR;
  /**
    Fatal logging level.
     
    This level enables logging for fatal errors only.
   */
  public static final int FATAL = LSConsoleLogLevel.FATAL;
}
