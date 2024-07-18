package com.lightstreamer.internal;

import haxe.atomic.AtomicBool;
import sys.thread.Thread;
import com.lightstreamer.internal.impl.sys.LsHttp;
import com.lightstreamer.internal.PlatformApi.IHttpClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class HttpClient implements IHttpClient {
  final _thread: Thread;
  final _disposed = new AtomicBool(false);

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>,
    _onText: (HttpClient, String)->Void, 
    _onError: (HttpClient, String)->Void, 
    _onDone: HttpClient->Void) 
  {
    streamLogger.logDebug('HTTP sending: $url $body headers($headers)');
    _thread = Thread.create(() -> {
			var req = new LsHttp(url);
			req.onData = line -> {
        if (isDisposed()) {
          return;
        }
        streamLogger.logDebug('HTTP event: text($line)');
        _onText(this, line);
      }
			req.onError = error -> {
        if (isDisposed()) {
          return;
        }
        streamLogger.logDebug('HTTP event: error($error)');
        _onError(this, error);
      }
      req.onDone = () -> {
        if (isDisposed()) {
          return;
        }
        streamLogger.logDebug("HTTP event: complete");
        _onDone(this);
      }
      req.onStatus = _ -> {
        // extract the cookies from the Set-Cookie headers and add them to the cookie jar
        var hs = req.getResponseHeaderValues("Set-Cookie");
        if (hs != null) {
          CookieHelper.instance.addCookies(url, hs);
        }
      }
			// set additional headers
			req.setHeader("Content-Type", "application/x-www-form-urlencoded; charset=utf-8");
			if (headers != null) {
				for (k => v in headers) {
					req.setHeader(k, v);
				}
			}
      // extract the cookies from the cookie jar and set the Cookie header
      var cookies = CookieHelper.instance.getCookieHeader(url);
      if (cookies.length > 0) {
        req.setHeader("Cookie", cookies);
      }
			//
			req.setPostData(body);
			req.request(true);
		});
  }

  public function dispose(): Void {
    if (!_disposed.load()) {
      streamLogger.logDebug("HTTP disposing");
      _disposed.store(true);
      _thread.sendMessage("close");
    }
  }

  public function isDisposed(): Bool {
    return _disposed.load();
  }
}