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
import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.internal.PlatformApi.IHttpClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class HttpClient extends HttpClientPy implements IHttpClient {
  final onText: (HttpClient, String)->Void;
  final onError: (HttpClient, String)->Void;
  final onDone: HttpClient->Void;

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>,
    proxy: Null<Proxy>,
    sslContext: Null<SSLContext>,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
      super();
      streamLogger.logDebug('HTTP sending: $url $body headers($headers)');
      this.onText = onText;
      this.onError = onError;
      this.onDone = onDone;
      var nHeaders = headers == null ? null : new NativeStringMap<String>(headers);
      var nProxy = proxy != null ? ClientCommon.buildProxy(proxy) : null;
      this.sendAsync(url, body, nHeaders, nProxy, sslContext);
  }

  override public function dispose(): Void {
    streamLogger.logDebug("HTTP disposing");
    super.dispose();
  }

  override public function on_text(client: HttpClientPy, line: String): Void {
    streamLogger.logDebug('HTTP event: text($line)');
    this.onText(this, line);
  }

  override public function on_error(client: HttpClientPy, error: python.Exceptions.BaseException): Void {
    var msg = python.Syntax.code("str({0})", error);
    streamLogger.logDebugEx2('HTTP event: error(${msg})', error);
    this.onError(this, msg);
  }

  override public function on_done(client: HttpClientPy): Void {
    streamLogger.logDebug("HTTP event: complete");
    this.onDone(this);
  }
}