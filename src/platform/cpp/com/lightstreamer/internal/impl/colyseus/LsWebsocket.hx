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

  // adapted from WebSocketGeneric.initialize
  override function initialize(uri:String, protocols:Array<String> = null, origin:String = null, debug:Bool = true) {
    if (origin == null) origin = "http://127.0.0.1/";
    this.protocols = protocols;
    this.origin = origin;
    this.key = Base64.encode(Crypto.getSecureRandomBytes(16));
    this.debug = debug;
    var reg = ~/^(\w+?):\/\/([\w\.-]+)(:(\d+))?(\/.*)?$/;
    //var reg = ~/^(\w+?):/;
    if (!reg.match(uri)) throw 'Uri not matching websocket uri "${uri}"';
    scheme = reg.matched(1);
    switch (scheme) {
        case "ws": secure = false;
        case "wss": secure = true;
        default: throw 'Scheme "${scheme}" is not a valid websocket scheme';
    }
    host = reg.matched(2);
    port = (reg.matched(4) != null) ? Std.parseInt(reg.matched(4)) : (secure ? 443 : 80);
    path = reg.matched(5);
    if (path == null) path = '/';
    //trace('$scheme, $host, $port, $path');

    // BEGIN PATCH
    // socket = Socket2.create(host, port, secure, debug);
    
    socket = new LsSocket(host, port, debug).initialize(secure);
    // END PATCH
    
    state = State.Handshake;
    socket.onconnect = function() {
        _debug('socket connected');
        writeBytes(prepareClientHandshake(path, host, port, key, origin));
        //this.onopen();
    };
    commonInitialize();

    return this;
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

    // BEGIN PATCH
    for (k => v in _additionalHeaders) {
      lines.push('$k: $v');
    }
    // END PATCH

    return Utf8Encoder.encode(lines.join("\r\n") + "\r\n\r\n");
  }
}