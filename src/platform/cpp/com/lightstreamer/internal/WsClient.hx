package com.lightstreamer.internal;

import haxe.net.WebSocket;
import haxe.atomic.AtomicBool;
import sys.Http;
import sys.thread.Thread;
import com.lightstreamer.client.Proxy.LSProxy as Proxy;
import com.lightstreamer.internal.PlatformApi.IWsClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class WsClient implements IWsClient {
  final _thread: Thread;
  final _disposed = new AtomicBool(false);

  public function new(url: String, 
    headers: Null<Map<String, String>>,
    proxy: Null<Proxy>,
    _onOpen: WsClient->Void,
    _onText: (WsClient, String)->Void, 
    _onError: (WsClient, String)->Void)
  {
    streamLogger.logDebug('WS connecting: $url headers($headers) proxy($proxy)');
    _thread = Thread.create(() -> {
      try {
        url = ~/^http/.replace(url, "ws");
        var ws = WebSocket.create(url, [Constants.FULL_TLCP_VERSION], false);
        ws.onopen = () -> {
          if (isDisposed()) {
            return;
          }
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