package com.lightstreamer.log;

import com.lightstreamer.log.LSConsoleLoggerProvider;

/**
  Simple concrete logging provider that logs on the system console.
 
  To be used, an instance of this class has to be passed to the library through the {@link com.lightstreamer.client.LightstreamerClient#setLoggerProvider(LoggerProvider)}.
 */
public class ConsoleLoggerProvider implements LoggerProvider {
  final LSConsoleLoggerProvider delegate;

  /**
    Creates an instace of the concrete system console logger.
     
    @param level The desired logging level. See {@link ConsoleLogLevel}.
  */
  public ConsoleLoggerProvider(int level) {
    this.delegate = new LSConsoleLoggerProvider(level);
  }

  public Logger getLogger(String category) {
    return delegate.getLogger(category);
  }
}