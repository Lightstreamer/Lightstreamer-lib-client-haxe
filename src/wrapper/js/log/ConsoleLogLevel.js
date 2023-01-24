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