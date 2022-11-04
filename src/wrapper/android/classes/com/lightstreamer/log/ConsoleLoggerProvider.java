package com.lightstreamer.log;

/**
  Simple concrete logging provider that logs on the system console.
 
  To be used, an instance of this class has to be passed to the library through the {@link com.lightstreamer.client.LightstreamerClient#setLoggerProvider(LoggerProvider)}.
 */
public class ConsoleLoggerProvider implements LoggerProvider {
  final com.lightstreamer.log.internal.ConsoleLoggerProvider delegate;

  /**
    Creates an instace of the concrete system console logger.
     
    @param level The desired logging level. See {@link ConsoleLogLevel}.
  */
  public ConsoleLoggerProvider(int level) {
    this.delegate = new com.lightstreamer.log.internal.ConsoleLoggerProvider(level);
  }

  public Logger getLogger(String category) {
    return delegate.getLogger(category);
  }
}