package com.lightstreamer.internal.impl.colyseus;

import haxe.net.Crypto;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.ds.StringMap;
import haxe.net.impl.WebSocketGeneric;

@:nullSafety(Off)
class LsWebsocket extends WebSocketGeneric {
  final _additionalHeaders = new StringMap<String>();

  public function new(uri:String, protocols:Array<String> = null, origin:String = null, debug:Bool = true, additionalHeaders: Map<String, String> = null) {
    if (additionalHeaders != null) {
      for (k => v in additionalHeaders) {
        _additionalHeaders.set(k, v);
      }
    }
    super();
    initialize(uri, protocols, origin, debug);
  }

  // adapted from WebSocketGeneric.prepareClientHandshake
  override function prepareClientHandshake(url:String, host:String, port:Int, key:String, origin:String):Bytes {
    var lines = [];
    lines.push('GET ${url} HTTP/1.1');
    lines.push('Host: ${host}:${port}');
    lines.push('Pragma: no-cache');
    lines.push('Cache-Control: no-cache');
    lines.push('Upgrade: websocket');
    if (this.protocols != null) {
        lines.push('Sec-WebSocket-Protocol: ' + this.protocols.join(', '));
    }
    lines.push('Sec-WebSocket-Version: 13');
    lines.push('Connection: Upgrade');
    lines.push("Sec-WebSocket-Key: " + key);
    lines.push('Origin: ${origin}');
    lines.push('User-Agent: Mozilla/5.0');

    for (k => v in _additionalHeaders) {
      lines.push('$k: $v');
    }

    return Utf8Encoder.encode(lines.join("\r\n") + "\r\n\r\n");
}
}