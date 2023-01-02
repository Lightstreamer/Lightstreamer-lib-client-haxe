/*
 * Copyright (c) 2004-2019 Lightstreamer s.r.l., Via Campanini, 6 - 20124 Milano, Italy.
 * All rights reserved.
 * www.lightstreamer.com
 *
 * This software is the confidential and proprietary information of
 * Lightstreamer s.r.l.
 * You shall not disclose such Confidential Information and shall use it
 * only in accordance with the terms of the license agreement you entered
 * into with Lightstreamer s.r.l.
 */
namespace com.lightstreamer.log
{

  /// <summary>Logging level. See <seealso cref="ConsoleLoggerProvider"/>.</summary>
  public class ConsoleLogLevel {

    private ConsoleLogLevel() {}

    /// <summary>Trace logging level.
    ///
    /// This level enables all logging.</summary>
    public static readonly int TRACE = LSConsoleLogLevel.TRACE;
    /// <summary>Debug logging level.
    ///
    /// This level enables all logging except tracing.</summary>
    public static readonly int DEBUG = LSConsoleLogLevel.DEBUG;
    /// <summary>Info logging level.
    /// 
    /// This level enables logging for information, warnings, errors and fatal errors.</summary>
    public static readonly int INFO = LSConsoleLogLevel.INFO;
    /// <summary>Warn logging level.
    ///
    /// This level enables logging for warnings, errors and fatal errors.</summary>
    public static readonly int WARN = LSConsoleLogLevel.WARN;
    /// <summary>Error logging level.
    ///
    /// This level enables logging for errors and fatal errors.</summary>
    public static readonly int ERROR = LSConsoleLogLevel.ERROR;
    /// <summary>Fatal logging level.
    ///
    /// This level enables logging for fatal errors only.</summary>
    public static readonly int FATAL = LSConsoleLogLevel.FATAL;
  }
}