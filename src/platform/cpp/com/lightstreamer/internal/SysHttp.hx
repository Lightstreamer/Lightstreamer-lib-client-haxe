package com.lightstreamer.internal;

import sys.Http;
import sys.thread.Thread;

class SysHttp extends Http {

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

  override function success(data: haxe.io.Bytes) {
    onDone();
	}

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
			// try {
			// 	while (true) {
			// 		var len = sock.input.readBytes(buf, 0, bufsize);
			// 		if (!readChunk(chunk_re, api, buf, len))
			// 			break;
			// 	}
			// } catch (e:haxe.io.Eof) {
			// 	throw "Transfer aborted";
			// }

      // BEGIN PATCH
      throw new haxe.Exception("Chunked encoding not supported");
      // END PATCH
		} else if (size == null) {
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

      // BEGIN PATCH
      throw new haxe.Exception("Unlimited length not supported");
      // END PATCH
		} else {
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

      // BEGIN PATCH
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