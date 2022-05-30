package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.internal.PlatformApi.IHttpClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class HttpClient extends HttpClientPy implements IHttpClient {
  final onText: (HttpClient, String)->Void;
  final onError: (HttpClient, String)->Void;
  final onDone: HttpClient->Void;

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>,
    onText: (HttpClient, String)->Void, 
    onError: (HttpClient, String)->Void, 
    onDone: HttpClient->Void) {
      super();
      streamLogger.logDebug('HTTP sending: $url $body headers($headers)');
      this.onText = onText;
      this.onError = onError;
      this.onDone = onDone;
      var nHeaders = headers == null ? null : new NativeStringMap(headers);
      this.sendAsync(url, body, nHeaders);
  }

  override public function dispose(): Void {
    streamLogger.logDebug("HTTP disposing");
    super.dispose();
  }

  override public function on_text(client: HttpClientPy, line: String): Void {
    streamLogger.logDebug('HTTP event: text($line)');
    this.onText(this, line);
  }

  override public function on_error(client: HttpClientPy, error: python.Exceptions.BaseException): Void {
    var msg = python.Syntax.code("str({0})", error);
    streamLogger.logDebug('HTTP event: error(${msg})', error);
    this.onError(this, msg);
  }

  override public function on_done(client: HttpClientPy): Void {
    streamLogger.logDebug("HTTP event: complete");
    this.onDone(this);
  }
}