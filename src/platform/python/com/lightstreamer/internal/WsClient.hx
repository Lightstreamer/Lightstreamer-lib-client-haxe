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
import com.lightstreamer.internal.PlatformApi.IWsClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class WsClient extends WsClientPy implements IWsClient {
  final onOpen: WsClient->Void;
  final onText: (WsClient, String)->Void;
  final onError: (WsClient, String)->Void;

  public function new(url: String,
    headers: Null<Map<String, String>>,
    proxy: Null<Proxy>, 
    sslContext: Null<SSLContext>,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    super();
    streamLogger.logDebug('WS connecting: $url headers($headers)');
    this.onOpen = onOpen;
    this.onText = onText;
    this.onError = onError;
    var nHeaders = headers == null ? null : new NativeStringMap<String>(headers);
    var nProxy = proxy != null ? ClientCommon.buildProxy(proxy) : null;
    this.connectAsync(url, Constants.FULL_TLCP_VERSION, nHeaders, nProxy, sslContext);
  }

  public function send(txt: String) {
    streamLogger.logDebug('WS sending: $txt');
    sendAsync(txt);
  }

  override public function dispose(): Void {
    streamLogger.logDebug("WS disposing");
    super.dispose();
  }

  override public function on_open(client: WsClientPy) {
    streamLogger.logDebug('WS event: open');
    this.onOpen(this);
  }

  override public function on_text(client: WsClientPy, line: String) {
    streamLogger.logDebug('WS event: text($line)');
    this.onText(this, line);
  }

  override public function on_error(client: WsClientPy, error: python.Exceptions.BaseException) {
    var msg = python.Syntax.code("str({0})", error);
    streamLogger.logDebugEx2('WS event: error(${msg})', error);
    this.onError(this, msg);
  }
}