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