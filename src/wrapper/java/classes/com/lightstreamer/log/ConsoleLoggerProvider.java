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
package com.lightstreamer.log;

import com.lightstreamer.log.LSConsoleLoggerProvider;

/**
  Simple concrete logging provider that logs on the system console.
 
  To be used, an instance of this class has to be passed to the library through the {@link com.lightstreamer.client.LightstreamerClient#setLoggerProvider(LoggerProvider)}.
 */
public class ConsoleLoggerProvider implements LoggerProvider {
  final LSConsoleLoggerProvider delegate;

  /**
    Creates an instance of the concrete system console logger.
     
    @param level The desired logging level. See {@link ConsoleLogLevel}.
  */
  public ConsoleLoggerProvider(int level) {
    this.delegate = new LSConsoleLoggerProvider(level);
  }

  public Logger getLogger(String category) {
    return delegate.getLogger(category);
  }
}