package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi.IWsClient;
import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.client.Proxy;
import com.lightstreamer.cs.WsClientCs;
import com.lightstreamer.log.LoggerTools;

using StringTools;
using com.lightstreamer.log.LoggerTools;

class WsClient extends WsClientCs implements IWsClient {
  final onOpen: WsClient->Void;
  final onText: (WsClient, String)->Void;
  final onError: (WsClient, String)->Void;

  public function new(url: String,
    headers: Null<Map<String, String>>, 
    proxy: Null<Proxy>,
    certificateValidator: Null<cs.system.net.security.RemoteCertificateValidationCallback>,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    super();
    if (url.startsWith("https://")) {
      url = url.replace("https://", "wss://");
    } else if (url.startsWith("http://")) {
      url = url.replace("http://", "ws://");
    }
    streamLogger.logDebug('WS connecting: $url headers($headers) proxy($proxy) certificateValidator(${certificateValidator != null})');
    this.onOpen = onOpen;
    this.onText = onText;
    this.onError = onError;
    var nHeaders = headers == null ? null : new NativeStringMap<String>(headers);
    @:nullSafety(Off)
    var nProxy = proxy == null ? null : new com.lightstreamer.cs.Proxy(proxy.host, proxy.port, proxy.user, proxy.password);
    @:nullSafety(Off)
    this.ConnectAsync(url, Constants.FULL_TLCP_VERSION, nHeaders, nProxy, certificateValidator);
  }

  public function send(txt: String) {
    streamLogger.logDebug('WS sending: $txt');
    SendAsync(txt);
  }

  public function dispose(): Void {
    streamLogger.logDebug("WS disposing");
    Dispose();
  }

  public function isDisposed(): Bool {
    return IsDisposed();
  }

  overload override public function OnOpen(client: WsClientCs) {
    streamLogger.logDebug('WS event: open');
    this.onOpen(this);
  }

  overload override public function OnText(client: WsClientCs, line: String) {
    streamLogger.logDebug('WS event: text($line)');
    this.onText(this, line);
  }

  overload override public function OnError(client: WsClientCs, error: cs.system.Exception) {
    streamLogger.logDebug('WS event: error(${error.Message})', error);
    this.onError(this, error.Message);
  }
}