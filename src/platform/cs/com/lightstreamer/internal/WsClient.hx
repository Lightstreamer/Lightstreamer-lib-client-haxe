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

import com.lightstreamer.internal.PlatformApi.IWsClient;
import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.client.Proxy.LSProxy as Proxy;
import com.lightstreamer.cs.WsClientCs;
import com.lightstreamer.log.LoggerTools;

using StringTools;
using com.lightstreamer.log.LoggerTools;

class WsClient extends WsClientCs implements IWsClient {
  final onOpen: WsClient->Void;
  final onText: (WsClient, String)->Void;
  final onError: (WsClient, String)->Void;

  public function new(url: String,
    headers: Null<Map<String, String>>, 
    proxy: Null<Proxy>,
    certificateValidator: Null<cs.system.net.security.RemoteCertificateValidationCallback>,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    super();
    if (url.startsWith("https://")) {
      url = url.replace("https://", "wss://");
    } else if (url.startsWith("http://")) {
      url = url.replace("http://", "ws://");
    }
    streamLogger.logDebug('WS connecting: $url headers($headers) proxy($proxy) certificateValidator(${certificateValidator != null})');
    this.onOpen = onOpen;
    this.onText = onText;
    this.onError = onError;
    var nHeaders = headers == null ? null : new NativeStringMap<String>(headers);
    @:nullSafety(Off)
    var nProxy = proxy == null ? null : new com.lightstreamer.cs.Proxy(proxy.host, proxy.port, proxy.user, proxy.password);
    @:nullSafety(Off)
    this.ConnectAsync(url, Constants.FULL_TLCP_VERSION, nHeaders, nProxy, certificateValidator);
  }

  public function send(txt: String) {
    streamLogger.logDebug('WS sending: $txt');
    SendAsync(txt);
  }

  public function dispose(): Void {
    streamLogger.logDebug("WS disposing");
    Dispose();
  }

  public function isDisposed(): Bool {
    return IsDisposed();
  }

  overload override public function OnOpen(client: WsClientCs) {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('WS event: open');
    this.onOpen(this);
  }

  overload override public function OnText(client: WsClientCs, line: String) {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('WS event: text($line)');
    this.onText(this, line);
  }

  overload override public function OnError(client: WsClientCs, error: cs.system.Exception) {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebugEx2('WS event: error(${error.Message})', error);
    this.onError(this, error.Message);
  }
}