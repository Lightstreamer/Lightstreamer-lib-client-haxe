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
  /**
   * This is a dummy constructor not to be used in any case.
   * @constructor
   * 
   * @exports ConsoleLogLevel
   * @class  Logging level.
   */
var ConsoleLogLevel = function() {
};

  /**
   * Trace logging level.
   * 
   * This level enables all logging.
   * @type {number}
   * @const
   */
  ConsoleLogLevel.TRACE = LSConsoleLogLevel.TRACE;
  /**
   * Debug logging level.
   * 
   * This level enables all logging except tracing.
   * @type {number}
   * @const
   */
  ConsoleLogLevel.DEBUG = LSConsoleLogLevel.DEBUG;
  /**
   * Info logging level.
   * 
   * This level enables logging for information, warnings, errors and fatal errors.
   * @type {number}
   * @const
   */
  ConsoleLogLevel.INFO = LSConsoleLogLevel.INFO;
  /**
   * Warn logging level.
   * 
   * This level enables logging for warnings, errors and fatal errors.
   * @type {number}
   * @const
   */
  ConsoleLogLevel.WARN = LSConsoleLogLevel.WARN;
  /**
   * Error logging level.
   * 
   * This level enables logging for errors and fatal errors.
   * @type {number}
   * @const
   */
  ConsoleLogLevel.ERROR = LSConsoleLogLevel.ERROR;
  /**
   * Fatal logging level.
   * 
   * This level enables logging for fatal errors only.
   * @type {number}
   * @const
   */
  ConsoleLogLevel.FATAL = LSConsoleLogLevel.FATAL;