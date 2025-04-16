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

  var responseHeaders: haxe.ds.StringMap<String>;
  var responseHeadersSameKey: Map<String, Array<String>>;

  /**
		Returns an array of values for a single response header or returns
		null if no such header exists.
		This method can be useful when you need to get a multiple headers with
		the same name (e.g. `Set-Cookie`), that are unreachable via the
		`responseHeaders` variable.
	**/
  // adapted from sys.Http.getResponseHeaderValues
  public function getResponseHeaderValues(key:String): Null<Array<String>> {
		var key = key.toLowerCase(); // header names are stored in lower case

		var array = responseHeadersSameKey?.get(key); // responseHeadersSameKey may be not initialized
		if (array == null) {
			var singleValue = responseHeaders.get(key);
			return (singleValue == null) ? null : [ singleValue ];
		} else {
			return array;
		}
	}

  // adapted from WebSocketGeneric.validateServerHandshakeHeader
  override function validateServerHandshakeHeader():Void {
    _debug('HTTP request: \n$httpHeader');

    var requestLines = httpHeader.split('\r\n');
    requestLines.pop();
    requestLines.pop();

    var firstLine = requestLines.shift();
    var regexp = ~/^HTTP\/1.1 ([0-9]+) ?(.*)$/;
    if (!regexp.match(firstLine)) throw 'First line of HTTP response is invalid: "$firstLine"';
    var statusCode:String = regexp.matched(1);
    if (statusCode != "101") throw 'Status code differed from 101 indicates that handshake has not succeeded. Actual status code: ${statusCode}.';

    // BEGIN PATCH
    // adapted from sys.Http.readHttpResponse
    var headers = requestLines;
    responseHeaders = new haxe.ds.StringMap();
		for (hline in headers) {
			var a = hline.split(": ");
			var hname = a.shift().toLowerCase();
			var hval = if (a.length == 1) a[0] else a.join(": ");
			hval = StringTools.ltrim(StringTools.rtrim(hval));

			{
				var previousValue = responseHeaders.get(hname);
				if (previousValue != null) {
					if (responseHeadersSameKey == null) {
						responseHeadersSameKey = new haxe.ds.Map<String, Array<String>>();
					}
					var array = responseHeadersSameKey.get(hname);
					if (array == null) {
						array = new Array<String>();
						array.push(previousValue);
						responseHeadersSameKey.set(hname, array);
					}
					array.push(hval);
				}
			}
			responseHeaders.set(hname, hval);
		}
    // END PATCH
  }
}