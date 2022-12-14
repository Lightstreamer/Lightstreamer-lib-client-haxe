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

  /// Logging level.
  public class ConsoleLogLevel {

    private ConsoleLogLevel() {}

    /// Trace logging level.
    ///
    /// This level enables all logging.
    public static readonly int TRACE = LSConsoleLogLevel.TRACE;
    /// Debug logging level.
    ///
    /// This level enables all logging except tracing.
    public static readonly int DEBUG = LSConsoleLogLevel.DEBUG;
    /// Info logging level.
    /// 
    /// This level enables logging for information, warnings, errors and fatal errors.
    public static readonly int INFO = LSConsoleLogLevel.INFO;
    /// Warn logging level.
    ///
    /// This level enables logging for warnings, errors and fatal errors.
    public static readonly int WARN = LSConsoleLogLevel.WARN;
    /// Error logging level.
    ///
    /// This level enables logging for errors and fatal errors.
    public static readonly int ERROR = LSConsoleLogLevel.ERROR;
    /// Fatal logging level.
    ///
    /// This level enables logging for fatal errors only.
    public static readonly int FATAL = LSConsoleLogLevel.FATAL;
  }
}