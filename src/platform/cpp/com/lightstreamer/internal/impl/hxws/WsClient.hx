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
package com.lightstreamer.internal.impl.hxws;

import com.lightstreamer.internal.Threads.sessionThread;
import haxe.atomic.AtomicBool;
import com.lightstreamer.internal.PlatformApi.IWsClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class WsClient implements IWsClient {
  final _disposed = new AtomicBool(false);
  final _ws: LsWebsocket;

  public function new(url: String, 
    headers: Null<Map<String, String>>,
    _onOpen: WsClient->Void,
    _onText: (WsClient, String)->Void, 
    _onError: (WsClient, String)->Void)
  {
    streamLogger.logDebug('WS connecting: $url headers($headers)');
    url = ~/^http/.replace(url, "ws");
    _ws = new LsWebsocket(url, Constants.FULL_TLCP_VERSION, headers);
    _ws.onopen = () -> {
      if (isDisposed()) {
        return;
      }
      streamLogger.logDebug('WS event: open');
      _onOpen(this);
    }
    _ws.onmessage = msg -> {
      if (isDisposed()) {
        return;
      }
      var text = switch (msg) {
        case StrMessage(content): content;
        case _: "";
      }
      for (line in text.split("\r\n")) {
        if (isDisposed()) {
          return;
        }
        if (line == "") continue;
        streamLogger.logDebug('WS event: text($line)');
        _onText(this, line);
      }
    }
    _ws.onerror = _error -> {
      if (isDisposed()) {
        return;
      }
      var error = Std.string(_error);
      streamLogger.logDebug('WS event: error($error)');
      _onError(this, error);
    }
    sessionThread.submit(() -> 
      try {
        _ws.open();
      } catch(ex) {
        if (isDisposed()) {
          return;
        }
        streamLogger.logErrorEx('WS event: error(${ex.message})', ex);
        _onError(this, ex.message);
      }
    );
  }

  public function dispose(): Void {
    if (!_disposed.load()) {
      streamLogger.logDebug("WS disposing");
      _disposed.store(true);
      _ws.close();
    }
  }

  public function isDisposed(): Bool {
    return _disposed.load();
  }

  public function send(txt: String): Void {
    if (!_disposed.load()) {
      streamLogger.logDebug('WS sending: $txt');
      _ws.send(txt);
    }
  }
}