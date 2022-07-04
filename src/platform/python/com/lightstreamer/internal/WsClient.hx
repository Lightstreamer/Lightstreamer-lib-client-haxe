package com.lightstreamer.internal;

import com.lightstreamer.client.Proxy;
import com.lightstreamer.internal.NativeTypes.NativeStringMap;
import com.lightstreamer.internal.PlatformApi.IWsClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

class WsClient extends WsClientPy implements IWsClient {
  final onOpen: WsClient->Void;
  final onText: (WsClient, String)->Void;
  final onError: (WsClient, String)->Void;

  public function new(url: String,
    headers: Null<Map<String, String>>,
    proxy: Null<Proxy>, 
    sslContext: Null<SSLContext>,
    onOpen: WsClient->Void,
    onText: (WsClient, String)->Void, 
    onError: (WsClient, String)->Void) {
    super();
    streamLogger.logDebug('WS connecting: $url headers($headers)');
    this.onOpen = onOpen;
    this.onText = onText;
    this.onError = onError;
    var nHeaders = headers == null ? null : new NativeStringMap<String>(headers);
    var nProxy = proxy != null ? ClientCommon.buildProxy(proxy) : null;
    this.connectAsync(url, Constants.FULL_TLCP_VERSION, nHeaders, nProxy, sslContext);
  }

  public function send(txt: String) {
    streamLogger.logDebug('WS sending: $txt');
    sendAsync(txt);
  }

  override public function dispose(): Void {
    streamLogger.logDebug("WS disposing");
    super.dispose();
  }

  override public function on_open(client: WsClientPy) {
    streamLogger.logDebug('WS event: open');
    this.onOpen(this);
  }

  override public function on_text(client: WsClientPy, line: String) {
    streamLogger.logDebug('WS event: text($line)');
    this.onText(this, line);
  }

  override public function on_error(client: WsClientPy, error: python.Exceptions.BaseException) {
    var msg = python.Syntax.code("str({0})", error);
    streamLogger.logDebug('WS event: error(${msg})', error);
    this.onError(this, msg);
  }
}