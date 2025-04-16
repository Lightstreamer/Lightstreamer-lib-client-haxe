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

#if python
@:pythonImport("lightstreamer.client", "ConsoleLogLevel")
#end
#if js @:native("ConsoleLogLevel") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ConsoleLogLevel") #end
extern class ConsoleLogLevel {
  public static final TRACE: Int;
  public static final DEBUG: Int;
  public static final INFO: Int;
  public static final WARN: Int;
  public static final ERROR: Int;
  public static final FATAL: Int;
}

#if python
@:pythonImport("lightstreamer.client", "ConsoleLoggerProvider")
#end
#if js @:native("ConsoleLoggerProvider") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ConsoleLoggerProvider") #end
extern class ConsoleLoggerProvider implements LoggerProvider {
  public function new(level: Int);
  public function getLogger(category: String): Logger;
}