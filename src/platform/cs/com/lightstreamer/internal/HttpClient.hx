package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.cs.HttpClientCs;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;

class HttpClient extends HttpClientCs {
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
      @:nullSafety(Off)
      this.SendAsync(url, body, nHeaders);
  }

  public function dispose(): Void {
    streamLogger.logDebug("HTTP disposing");
    Dispose();
  }

  public function isDisposed(): Bool {
    return IsDisposed();
  }

  overload override public function OnText(client: HttpClientCs, line: String): Void {
    streamLogger.logDebug('HTTP event: text($line)');
    this.onText(this, line);
  }

  overload override public function OnError(client: HttpClientCs, error: cs.system.Exception): Void {
    streamLogger.logDebug('HTTP event: error(${error.Message})');
    this.onError(this, error.Message);
  }

  overload override public function OnDone(client: HttpClientCs): Void {
    streamLogger.logDebug("HTTP event: complete");
    this.onDone(this);
  }

  public static function setProxy(proxy: com.lightstreamer.client.Proxy) {
    @:nullSafety(Off)
    HttpClientCs.SetProxy(proxy.host, proxy.port, proxy.user, proxy.password);
  }

  public static function setRemoteCertificateValidationCallback(callback: cs.system.net.security.RemoteCertificateValidationCallback) {
    HttpClientCs.SetRemoteCertificateValidationCallback(callback);
  }
}