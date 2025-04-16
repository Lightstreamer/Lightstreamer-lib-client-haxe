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
import js.html.WebSocket;
import com.lightstreamer.log.LoggerTools;

using StringTools;
using com.lightstreamer.log.LoggerTools;

class WsClient implements IWsClient {
  final ws: WebSocket;
  var isCanceled = false;

  public function new(url: String,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    if (url.startsWith("https://")) {
      url = url.replace("https://", "wss://");
    } else if (url.startsWith("http://")) {
      url = url.replace("http://", "ws://");
    }
    streamLogger.logDebug('WS connecting: $url');
    this.ws = new WebSocket(url, Constants.FULL_TLCP_VERSION);
    ws.onopen = () -> {
      if (isCanceled) return;
      streamLogger.logDebug('WS event: open');
      onOpen(this);
    };
    ws.onmessage = evt -> {
      if (isCanceled) return;
      var text: String = evt.data;
      for (line in text.split("\r\n")) {
        if (isCanceled) return;
        if (line == "") continue;
        streamLogger.logDebug('WS event: text($line)');
        onText(this, line);
      }
    };
    ws.onerror = () -> {
      if (isCanceled) return;
      var msg = "Network error";
      streamLogger.logDebug('WS event: error($msg)');
      onError(this, msg);
      ws.close();
    };
    ws.onclose = evt -> {
      if (isCanceled) return;
      var msg =  "unexpected disconnection: " + evt.code + " - " + evt.reason;
      streamLogger.logDebug('WS event: error($msg)');
      onError(this, msg);
      ws.close();
    };
  }

  public function send(txt: String) {
    streamLogger.logDebug('WS sending: $txt');
    ws.send(txt);
  }

  public function dispose() {
    streamLogger.logDebug("WS disposing");
    isCanceled = true;
    ws.close();
  }

  inline public function isDisposed() {
    return isCanceled;
  }
}