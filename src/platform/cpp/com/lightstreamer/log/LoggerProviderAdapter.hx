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

class LoggerProviderAdapter implements LoggerProvider {
  final _provider: Pointer<NativeLoggerProvider>;

  public function new(provider: Pointer<NativeLoggerProvider>) {
    _provider = provider;
  }

  public function getLogger(category: String): Logger {
    var p = Pointer.fromStar(_provider.ref.getLogger(category));
    return new LoggerAdapter(p);
  }
}