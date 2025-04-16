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
package com.lightstreamer.internal.impl.colyseus;

import haxe.net.WebSocket;
import haxe.atomic.AtomicBool;
import sys.Http;
import sys.thread.Thread;
import com.lightstreamer.internal.PlatformApi.IWsClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class WsClient implements IWsClient {
  final _thread: Thread;
  final _disposed = new AtomicBool(false);

  public function new(url: String, 
    headers: Null<Map<String, String>>,
    _onOpen: WsClient->Void,
    _onText: (WsClient, String)->Void, 
    _onError: (WsClient, String)->Void)
  {
    streamLogger.logDebug('WS connecting: $url headers($headers)');
    _thread = Thread.create(() -> {
      try {
         // extract the cookies from the cookie jar and set the Cookie header
        var cookies = CookieHelper.instance.getCookieHeader(url);
        if (cookies.length > 0) {
          if (headers == null) {
            headers = [];
          }
          headers["Cookie"] = cookies;
        }
        //
        url = ~/^http/.replace(url, "ws"); // colyseus websocket requires ws or wss as scheme
        var ws = new LsWebsocket(url, [Constants.FULL_TLCP_VERSION], false, headers);
        ws.onopen = () -> {
          if (isDisposed()) {
            return;
          }
          // extract the cookies from the Set-Cookie headers and add them to the cookie jar
          var hs = ws.getResponseHeaderValues("Set-Cookie");
          if (hs != null) {
            CookieHelper.instance.addCookies(url, hs);
          }
          //
          streamLogger.logDebug('WS event: open');
          _onOpen(this);
        }
        ws.onmessageString = text -> {
          if (isDisposed()) {
            return;
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
        ws.onerror = error -> {
          if (isDisposed()) {
            return;
          }
          streamLogger.logDebug('WS event: error($error)');
          _onError(this, error);
        }
        while (!_disposed.load()) {
          ws.process();
          var m: Null<OpCode> = Thread.readMessage(false);
          if (m != null) {
            switch (m) {
            case WsSend(msg):
              ws.sendString(msg);
            case WsClose:
              break;
            }
          }
          Sys.sleep(0.1);
        }
        ws.close();
      } catch(ex) {
        if (isDisposed()) {
          return;
        }
        streamLogger.logErrorEx('WS event: error(${ex.message})', ex);
        _onError(this, ex.message);
      }
    });
  }

  public function dispose(): Void {
    if (!_disposed.load()) {
      streamLogger.logDebug("WS disposing");
      _disposed.store(true);
      _thread.sendMessage(WsClose);
    }
  }

  public function isDisposed(): Bool {
    return _disposed.load();
  }

  public function send(txt: String): Void {
    if (!_disposed.load()) {
      streamLogger.logDebug('WS sending: $txt');
      _thread.sendMessage(WsSend(txt));
    }
  }
}

private enum OpCode {
  WsSend(msg: String);
  WsClose;
}