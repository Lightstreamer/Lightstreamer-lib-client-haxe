package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.client.Proxy;
import com.lightstreamer.cs.WsClientCs;

class WsClient extends WsClientCs {
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
    this.onOpen = onOpen;
    this.onText = onText;
    this.onError = onError;
    var nHeaders = headers == null ? null : new NativeStringMap(headers);
    var nProxy = proxy == null ? null : new com.lightstreamer.cs.Proxy(proxy.host, proxy.port, proxy.user, proxy.password);
    this.ConnectAsync(url, Constants.Sec_WebSocket_Protocol, nHeaders, nProxy, certificateValidator);
  }

  public function send(txt: String) {
    SendAsync(txt);
  }

  public function dispose(): Void {
    Dispose();
  }

  public function isDisposed(): Bool {
    return IsDisposed();
  }

  overload override public function OnOpen(client: WsClientCs) {
    this.onOpen(this);
  }

  overload override public function OnText(client: WsClientCs, line: String) {
    this.onText(this, line);
  }

  overload override public function OnError(client: WsClientCs, error: cs.system.Exception) {
    this.onError(this, error.Message);
  }
}