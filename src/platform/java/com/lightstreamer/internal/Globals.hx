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

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();
  var trustManagerFactory: Null<java.javax.net.ssl.TrustManagerFactory>;

  function new() {}

  public function setTrustManagerFactory(factory: java.javax.net.ssl.TrustManagerFactory) {
    if (factory == null) {
      throw new java.lang.NullPointerException("Expected a non-null TrustManagerFactory");
    }
    if (trustManagerFactory != null) {
      throw new IllegalStateException("Trust manager factory already installed");
    }
    trustManagerFactory = factory;
  }

  public function getTrustManagerFactory(): Null<java.javax.net.ssl.TrustManagerFactory> {
    return trustManagerFactory;
  }

  public function clearTrustManager() {
    trustManagerFactory = null;
  }

  public function toString() return "{}";
}