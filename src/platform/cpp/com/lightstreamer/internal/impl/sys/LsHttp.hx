package com.lightstreamer.internal.impl.sys;

import haxe.io.BytesOutput;
import haxe.io.Bytes;
import sys.net.Host;
import sys.net.Socket;
import sys.Http;
import sys.thread.Thread;

class LsHttp extends Http {

	/** 
	 * **WARNING** proxy is broken: it doesn't work over https and doesn't support authentication
	 * 
	 * see https://github.com/HaxeFoundation/haxe/issues/6204 and https://github.com/HaxeFoundation/haxe/issues/8434
	 */
	static public function setProxy(host: String, port: Int, user: Null<String>, password: Null<String>) {
		var proxy: {port:Int, host:String, ?auth:{user:String, ?pass:String}} = { host: host, port: port };
		if (user != null) {
			proxy.auth = { user: user };
			if (password != null) {
				proxy.auth.pass = password;
			}
		}
		@:nullSafety(Off)
		Http.PROXY = proxy;
	}

  public dynamic function onDone() {}

	// **NB** the behavior of HttpBase.success has been changed
  override function success(data: haxe.io.Bytes) {
    onDone();
	}

	// adapted from Http.customRequest
	@:nullSafety(Off)
	override public function customRequest(post:Bool, api:haxe.io.Output, ?sock:sys.net.Socket, ?method:String) {
		this.responseAsString = null;
		this.responseBytes = null;
		var url_regexp = ~/^(https?:\/\/)?([a-zA-Z\.0-9_-]+)(:[0-9]+)?(.*)$/;
		if (!url_regexp.match(url)) {
			onError("Invalid URL");
			return;
		}
		var secure = (url_regexp.matched(1) == "https://");
		if (sock == null) {
			if (secure) {
				#if php
				sock = new php.net.SslSocket();
				#elseif java
				sock = new java.net.SslSocket();
				#elseif python
				sock = new python.net.SslSocket();
				#elseif (!no_ssl && (hxssl || hl || cpp || (neko && !(macro || interp) || eval) || (lua && !lua_vanilla)))
				// BEGIN PATCH
				// sock = new sys.ssl.Socket();

				var ctx = com.lightstreamer.internal.Globals.instance.getTrustManagerFactory();
				sock = ctx.createSocket();
				// END PATCH
				#elseif (neko || cpp)
				throw "Https is only supported with -lib hxssl";
				#else
				throw new haxe.exceptions.NotImplementedException("Https support in haxe.Http is not implemented for this target");
				#end
			} else {
				sock = new Socket();
			}
			sock.setTimeout(cnxTimeout);
		}
		var host = url_regexp.matched(2);
		var portString = url_regexp.matched(3);
		var request = url_regexp.matched(4);
		// ensure path begins with a forward slash
		// this is required by original URL specifications and many servers have issues if it's not supplied
		// see https://stackoverflow.com/questions/1617058/ok-to-skip-slash-before-query-string
		if (request.charAt(0) != "/") {
			request = "/" + request;
		}
		var port = if (portString == null || portString == "") secure ? 443 : 80 else Std.parseInt(portString.substr(1, portString.length - 1));

		var multipart = (file != null);
		var boundary = null;
		var uri = null;
		if (multipart) {
			post = true;
			boundary = Std.string(Std.random(1000))
				+ Std.string(Std.random(1000))
				+ Std.string(Std.random(1000))
				+ Std.string(Std.random(1000));
			while (boundary.length < 38)
				boundary = "-" + boundary;
			var b = new StringBuf();
			for (p in params) {
				b.add("--");
				b.add(boundary);
				b.add("\r\n");
				b.add('Content-Disposition: form-data; name="');
				b.add(p.name);
				b.add('"');
				b.add("\r\n");
				b.add("\r\n");
				b.add(p.value);
				b.add("\r\n");
			}
			b.add("--");
			b.add(boundary);
			b.add("\r\n");
			b.add('Content-Disposition: form-data; name="');
			b.add(file.param);
			b.add('"; filename="');
			b.add(file.filename);
			b.add('"');
			b.add("\r\n");
			b.add("Content-Type: " + file.mimeType + "\r\n" + "\r\n");
			uri = b.toString();
		} else {
			for (p in params) {
				if (uri == null)
					uri = "";
				else
					uri += "&";
				uri += StringTools.urlEncode(p.name) + "=" + StringTools.urlEncode('${p.value}');
			}
		}

		var b = new BytesOutput();
		if (method != null) {
			b.writeString(method);
			b.writeString(" ");
		} else if (post)
			b.writeString("POST ");
		else
			b.writeString("GET ");

		if (Http.PROXY != null) {
			b.writeString("http://");
			b.writeString(host);
			if (port != 80) {
				b.writeString(":");
				b.writeString('$port');
			}
		}
		b.writeString(request);

		if (!post && uri != null) {
			if (request.indexOf("?", 0) >= 0)
				b.writeString("&");
			else
				b.writeString("?");
			b.writeString(uri);
		}
		b.writeString(" HTTP/1.1\r\nHost: " + host + "\r\n");
		if (postData != null) {
			postBytes = Bytes.ofString(postData);
			postData = null;
		}
		if (postBytes != null)
			b.writeString("Content-Length: " + postBytes.length + "\r\n");
		else if (post && uri != null) {
			if (multipart || !Lambda.exists(headers, function(h) return h.name == "Content-Type")) {
				b.writeString("Content-Type: ");
				if (multipart) {
					b.writeString("multipart/form-data");
					b.writeString("; boundary=");
					b.writeString(boundary);
				} else
					b.writeString("application/x-www-form-urlencoded");
				b.writeString("\r\n");
			}
			if (multipart)
				b.writeString("Content-Length: " + (uri.length + file.size + boundary.length + 6) + "\r\n");
			else
				b.writeString("Content-Length: " + uri.length + "\r\n");
		}
		b.writeString("Connection: close\r\n");
		for (h in headers) {
			b.writeString(h.name);
			b.writeString(": ");
			b.writeString(h.value);
			b.writeString("\r\n");
		}
		b.writeString("\r\n");
		if (postBytes != null)
			b.writeFullBytes(postBytes, 0, postBytes.length);
		else if (post && uri != null)
			b.writeString(uri);
		try {
			if (Http.PROXY != null)
				sock.connect(new Host(Http.PROXY.host), Http.PROXY.port);
			else
				sock.connect(new Host(host), port);
			if (multipart)
				writeBody(b, file.io, file.size, boundary, sock)
			else
				writeBody(b, null, 0, null, sock);
			readHttpResponse(api, sock);
			sock.close();
		} catch (e:Dynamic) {
			try
				sock.close()
			catch (e:Dynamic) {};
			onError(Std.string(e));
		}
	}

	// adapted from Http.readHttpResponse
  @:nullSafety(Off)
  override function readHttpResponse(api:haxe.io.Output, sock:sys.net.Socket) {
		// READ the HTTP header (until \r\n\r\n)
		var b = new haxe.io.BytesBuffer();
		var k = 4;
		var s = haxe.io.Bytes.alloc(4);
		sock.setTimeout(cnxTimeout);
		while (true) {
			var p = 0;
			while (p != k) {
				try {
					p += sock.input.readBytes(s, p, k - p);
				}
				catch (e:haxe.io.Eof) { }
			}
			b.addBytes(s, 0, k);
			switch (k) {
				case 1:
					var c = s.get(0);
					if (c == 10)
						break;
					if (c == 13)
						k = 3;
					else
						k = 4;
				case 2:
					var c = s.get(1);
					if (c == 10) {
						if (s.get(0) == 13)
							break;
						k = 4;
					} else if (c == 13)
						k = 3;
					else
						k = 4;
				case 3:
					var c = s.get(2);
					if (c == 10) {
						if (s.get(1) != 13)
							k = 4;
						else if (s.get(0) != 10)
							k = 2;
						else
							break;
					} else if (c == 13) {
						if (s.get(1) != 10 || s.get(0) != 13)
							k = 1;
						else
							k = 3;
					} else
						k = 4;
				case 4:
					var c = s.get(3);
					if (c == 10) {
						if (s.get(2) != 13)
							continue;
						else if (s.get(1) != 10 || s.get(0) != 13)
							k = 2;
						else
							break;
					} else if (c == 13) {
						if (s.get(2) != 10 || s.get(1) != 13)
							k = 3;
						else
							k = 1;
					}
			}
		}
		#if neko
		var headers = neko.Lib.stringReference(b.getBytes()).split("\r\n");
		#else
		var headers = b.getBytes().toString().split("\r\n");
		#end
		var response = headers.shift();
		var rp = response.split(" ");
		var status = Std.parseInt(rp[1]);
		if (status == 0 || status == null)
			throw "Response status error";

		// remove the two lasts \r\n\r\n
		headers.pop();
		headers.pop();
		responseHeaders = new haxe.ds.StringMap();
		var size = null;
		var chunked = false;
		for (hline in headers) {
			var a = hline.split(": ");
			var hname = a.shift();
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
			switch (hname.toLowerCase()) {
				case "content-length":
					size = Std.parseInt(hval);
				case "transfer-encoding":
					chunked = (hval.toLowerCase() == "chunked");
			}
		}

		onStatus(status);

		var chunk_re = ~/^([0-9A-Fa-f]+)[ ]*\r\n/m;
		chunk_size = null;
		chunk_buf = null;

		var bufsize = 1024;
		var buf = haxe.io.Bytes.alloc(bufsize);
		if (chunked) {
			// BEGIN PATCH
			// try {
			// 	while (true) {
			// 		var len = sock.input.readBytes(buf, 0, bufsize);
			// 		if (!readChunk(chunk_re, api, buf, len))
			// 			break;
			// 	}
			// } catch (e:haxe.io.Eof) {
			// 	throw "Transfer aborted";
			// }

      throw new haxe.Exception("Chunked encoding not supported");
      // END PATCH
		} else if (size == null) {
			// BEGIN PATCH
			// if (!noShutdown)
			// 	sock.shutdown(false, true);
			// try {
			// 	while (true) {
			// 		var len = sock.input.readBytes(buf, 0, bufsize);
			// 		if (len == 0)
			// 			break;
			// 		api.writeBytes(buf, 0, len);
			// 	}
			// } catch (e:haxe.io.Eof) {}

      throw new haxe.Exception("Unlimited length not supported");
      // END PATCH
		} else {
			// BEGIN PATCH
			// api.prepare(size);
			// try {
			// 	while (size > 0) {
			// 		var len = sock.input.readBytes(buf, 0, if (size > bufsize) bufsize else size);
			// 		api.writeBytes(buf, 0, len);
			// 		size -= len;
			// 	}
			// } catch (e:haxe.io.Eof) {
			// 	throw "Transfer aborted";
			// }

      sock.setTimeout(0.1); // throws an Error.Blocked when the read timeout expires but no data is available
      while (true) {
        try {
          var s = sock.input.readLine();
          onData(s);
        } catch(ex: haxe.io.Error) {
          if (ex != haxe.io.Error.Blocked) {
            throw ex; 
          }
          var m = Thread.readMessage(false);
          if (m != null && m == "close") {
            // forced closing
            break;
          }
        } catch(ex: haxe.io.Eof) {
          // all data has been read
          break;
        }
      }
      // END PATCH
		}
		if (chunked && (chunk_size != null || chunk_buf != null))
			throw "Invalid chunk";
		if (status < 200 || status >= 400)
			throw "Http Error #" + status;
		api.close();
	}
}