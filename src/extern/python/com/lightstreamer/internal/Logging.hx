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
package com.lightstreamer.internal;

import python.KwArgs;
import python.lib.io.IOBase;

@:pythonImport("logging")
extern class Logging {
  static final CRITICAL: Int;
  static final ERROR: Int;
  static final WARNING: Int;
  static final INFO: Int;
  static final DEBUG: Int;
  static function basicConfig(kwargs: KwArgs<{?level: Int, ?format: String, stream: IOBase}>): Void;
  static function getLogger(name: String): Logger;
}

@:pythonImport("logging", Logger)
extern class Logger {
  function debug(msg: String): Void;
  function info(msg: String): Void;
  function warning(msg: String): Void;
  function error(msg: String): Void;
  function critical(msg: String): Void;
}