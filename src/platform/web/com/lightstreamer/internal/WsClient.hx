package com.lightstreamer.internal;

import js.html.WebSocket;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class WsClient {
  final ws: WebSocket;
  var isCanceled = false;

  public function new(url: String,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    streamLogger.logDebug('WS connecting: $url');
    this.ws = new WebSocket(url, Constants.FULL_TLCP_VERSION);
    ws.onopen = () -> {
      streamLogger.logDebug('WS event: open');
      onOpen(this);
    };
    ws.onmessage = evt -> {
      var text: String = evt.data;
      for (line in text.split("\r\n")) {
        if (line == "") continue;
        streamLogger.logDebug('WS event: text($line)');
        onText(this, line);
      }
    };
    ws.onerror = () -> {
      var msg = "Network error";
      streamLogger.logDebug('WS event: error($msg)');
      onError(this, msg);
      ws.close();
    };
    ws.onclose = evt -> {
      if (isCanceled) return;  // closing is expected
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