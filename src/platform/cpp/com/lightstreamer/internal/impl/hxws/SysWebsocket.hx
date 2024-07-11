package com.lightstreamer.internal.impl.hxws;

import hx.ws.WebSocket;

class SysWebsocket extends WebSocket {
  public function new(url: String, protocol: String, headers: Null<Map<String, String>>) {
    super(url, false);
    additionalHeaders.set("Sec-WebSocket-Protocol", protocol);
    if (headers != null) {
      for (k => v in headers) {
        additionalHeaders.set(k, v);
      }
    }
  }
}