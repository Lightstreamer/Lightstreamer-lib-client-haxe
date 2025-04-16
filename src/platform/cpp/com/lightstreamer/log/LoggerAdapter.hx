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

import cpp.Pointer;
import com.lightstreamer.internal.NativeTypes.NativeException;

class LoggerAdapter implements Logger {
  final _log: Pointer<NativeLogger>;

  public function new(log: Pointer<NativeLogger>) {
    _log = log;
  }

  public function fatal(line: String, ?exception: NativeException): Void {
    if (exception == null) 
      _log.ref.fatal(line);
    else {
      var s: String = '$line\n${exception.details()}';
      _log.ref.fatal(s);
    }
  }

  public function error(line: String, ?exception: NativeException): Void {
    if (exception == null) 
      _log.ref.error(line);
    else {
      var s: String = '$line\n${exception.details()}';
      _log.ref.error(s);
    }
  }

  public function warn(line: String, ?exception: NativeException): Void {
    if (exception == null) 
      _log.ref.warn(line);
    else {
      var s: String = '$line\n${exception.details()}';
      _log.ref.warn(s);
    }
  }

  public function info(line: String, ?exception: NativeException): Void {
    if (exception == null) 
      _log.ref.info(line);
    else {
      var s: String = '$line\n${exception.details()}';
      _log.ref.info(s);
    }
  }

  public function debug(line: String, ?exception: NativeException): Void {
    if (exception == null) 
      _log.ref.debug(line);
    else {
      var s: String = '$line\n${exception.details()}';
      _log.ref.debug(s);
    }
  }

  public function trace(line: String, ?exception: NativeException): Void {
    if (exception == null) 
      _log.ref.trace(line);
    else {
      var s: String = '$line\n${exception.details()}';
      _log.ref.trace(s);
    }
  }

  public function isFatalEnabled(): Bool {
    return _log.ref.isFatalEnabled();
  }

  public function isErrorEnabled(): Bool {
    return _log.ref.isErrorEnabled();
  }

  public function isWarnEnabled(): Bool {
    return _log.ref.isWarnEnabled();
  }

  public function isInfoEnabled(): Bool {
    return _log.ref.isInfoEnabled();
  }

  public function isDebugEnabled(): Bool {
    return _log.ref.isDebugEnabled();
  }
  
  public function isTraceEnabled(): Bool {
    return _log.ref.isTraceEnabled();
  }
}