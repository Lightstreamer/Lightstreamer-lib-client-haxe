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

import com.lightstreamer.client.Proxy.LSProxy as Proxy;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;
import cs.system.net.security.RemoteCertificateValidationCallback;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();
  var webProxy: Null<Proxy>;
  var validationCallback: Null<RemoteCertificateValidationCallback>;

  function new() {}

  public function setProxy(proxy: Null<Proxy>) {
    if (proxy == null) {
      throw new IllegalArgumentException("Expected a non-null Proxy");
    }
    if (webProxy != null && !webProxy.isEqualTo(proxy)) {
      throw new IllegalStateException("Proxy already installed");
    }
    if (webProxy == null) {
      webProxy = proxy;
      HttpClient.setProxy(proxy);
    }
  }

  public function setTrustManagerFactory(callback: RemoteCertificateValidationCallback) {
    if (callback == null) {
      throw new IllegalArgumentException("Expected a non-null RemoteCertificateValidationCallback");
    }
    if (validationCallback != null) {
      throw new IllegalStateException("RemoteCertificateValidationCallback already installed");
    }
    validationCallback = callback;
    HttpClient.setRemoteCertificateValidationCallback(callback);
  }

  public function getTrustManagerFactory(): Null<RemoteCertificateValidationCallback> {
    return validationCallback;
  }

  public function toString(): String return "{}";
}