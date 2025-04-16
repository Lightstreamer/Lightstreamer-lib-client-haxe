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

import com.lightstreamer.internal.PlatformApi.IHttpClient;
import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.cs.HttpClientCs;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class HttpClient extends HttpClientCs implements IHttpClient {
  final onText: (HttpClient, String)->Void;
  final onError: (HttpClient, String)->Void;
  final onDone: HttpClient->Void;

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
      super();
      streamLogger.logDebug('HTTP sending: $url $body headers($headers)');
      this.onText = onText;
      this.onError = onError;
      this.onDone = onDone;
      var nHeaders = headers == null ? null : new NativeStringMap<String>(headers);
      @:nullSafety(Off)
      this.SendAsync(url, body, nHeaders);
  }

  public function dispose(): Void {
    streamLogger.logDebug("HTTP disposing");
    Dispose();
  }

  public function isDisposed(): Bool {
    return IsDisposed();
  }

  overload override public function OnText(client: HttpClientCs, line: String): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('HTTP event: text($line)');
    this.onText(this, line);
  }

  overload override public function OnError(client: HttpClientCs, error: cs.system.Exception): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebugEx2('HTTP event: error(${error.Message})', error);
    this.onError(this, error.Message);
  }

  overload override public function OnDone(client: HttpClientCs): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug("HTTP event: complete");
    this.onDone(this);
  }

  public static function setProxy(proxy: com.lightstreamer.client.Proxy.LSProxy) {
    @:nullSafety(Off)
    HttpClientCs.SetProxy(proxy.host, proxy.port, proxy.user, proxy.password);
  }

  public static function setRemoteCertificateValidationCallback(callback: cs.system.net.security.RemoteCertificateValidationCallback) {
    HttpClientCs.SetRemoteCertificateValidationCallback(callback);
  }
}