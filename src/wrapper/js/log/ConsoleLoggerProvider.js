 /**
  * Creates an instace of the concrete system console logger.
  * @constructor
  *  
  * @param {number} level The desired logging level. See {@link ConsoleLogLevel}.
  * 
  * @exports ConsoleLoggerProvider
  * @class 
  * @implements {LoggerProvider}
  * Simple concrete logging provider that logs on the system console.
  * 
  * To be used, an instance of this class has to be passed to the library through the {@link LightstreamerClient#setLoggerProvider}.
  */
    var ConsoleLoggerProvider = function(level) {
      this.delegate = new LSConsoleLoggerProvider(level);
    };
  
    ConsoleLoggerProvider.prototype.getLogger = function(category) {
      return this.delegate.getLogger(category);
    };