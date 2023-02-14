package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi.IWsClient;
import haxe.DynamicAccess;
import js.npm.ws.WebSocket;
import com.lightstreamer.log.LoggerTools;

using StringTools;
using com.lightstreamer.log.LoggerTools;

class WsClient implements IWsClient {
  final ws: WebSocket;
  var isCanceled = false;

  public function new(url: String,
    headers: Null<Map<String, String>>,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    if (url.startsWith("https://")) {
      url = url.replace("https://", "wss://");
    } else if (url.startsWith("http://")) {
      url = url.replace("http://", "ws://");
    }
    streamLogger.logDebug('WS connecting: $url');
    var options: WebSocketOptions = cast {perMessageDeflate: false};
     // set headers
     if (headers != null) {
      options.headers = new DynamicAccess<String>();
      for (k => v in headers) {
        options.headers.set(k, v);
      }
    }
    // set cookies
    var cookies = CookieHelper.instance.getCookieHeader(url);
    switch cookies {
      case Some(header):
        if (options.headers == null) {
          options.headers = new DynamicAccess<String>();
        }
        options.headers.set("Cookie", header);
      case _:
    }
    // set url and options
    this.ws = new WebSocket(url, Constants.FULL_TLCP_VERSION, options);
    ws.on(Open, () -> {
      if (isCanceled) return;
      streamLogger.logDebug('WS event: open');
      onOpen(this);
    });
    ws.on(Message, data -> {
      if (isCanceled) return;
      var text: String = data.asBuffer(ws).toString("utf8");
      for (line in text.split("\r\n")) {
        if (isCanceled) return;
        if (line == "") continue;
        streamLogger.logDebug('WS event: text($line)');
        onText(this, line);
      }
    });
    ws.on(Error, error -> {
      if (isCanceled) return;
      var msg = 'Network error: ${error.name} - ${error.message}';
      streamLogger.logDebugEx2('WS event: error($msg)', error);
      onError(this, msg);
      ws.terminate();
    });
    ws.on(Close, (code, reason) -> {
      if (isCanceled) return;
      var msg =  "unexpected disconnection: " + code + " - " + reason;
      streamLogger.logDebug('WS event: error($msg)');
      onError(this, msg);
      ws.terminate();
    });
    ws.on(Upgrade, response -> {
      if (isCanceled) return;
      // store cookies
      var cookies = getCookies(response.headers);
      if (cookies != null) {
        CookieHelper.instance.addCookies(url, cookies);
      }
    });
  }

  function getCookies(headers: DynamicAccess<Array<String>>): Null<Array<String>> {
    @:nullSafety(Off)
    for (k => v in headers) {
      if (k.toLowerCase() == "set-cookie") {
        return v;
      }
    }
    return null;
  }

  public function send(txt: String) {
    streamLogger.logDebug('WS sending: $txt');
    @:nullSafety(Off)
    ws.send(txt, null, null);
  }

  public function dispose() {
    streamLogger.logDebug("WS disposing");
    isCanceled = true;
    ws.terminate();
  }

  inline public function isDisposed() {
    return isCanceled;
  }
}