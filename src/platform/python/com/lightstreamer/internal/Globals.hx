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

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();
  var sslContext: Null<SSLContext>;

  function new() {}

  public function setTrustManagerFactory(factory: SSLContext) {
    if (factory == null) {
      throw new IllegalArgumentException("Expected a non-null SSLContext");
    }
    if (sslContext != null) {
      throw new IllegalStateException("SSLContext already installed");
    }
    sslContext = factory;
  }

  public function getTrustManagerFactory(): Null<SSLContext> {
    return sslContext;
  }

  public function clearTrustManager() {
    sslContext = null;
  }

  public function toString(): String return "{}";
}