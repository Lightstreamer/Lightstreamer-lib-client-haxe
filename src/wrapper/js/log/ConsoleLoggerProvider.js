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
  * Creates an instance of the concrete system console logger.
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