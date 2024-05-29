package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi.IWsClient;
import cpp.Star;
import cpp.Reference;
import cpp.ConstCharStar;
import sys.thread.Thread;
import poco.net.ProxyConfig;
import com.lightstreamer.cpp.CppStringMap;
import com.lightstreamer.hxpoco.WsClientCpp;
import com.lightstreamer.client.Proxy.LSProxy as Proxy;
import com.lightstreamer.internal.Threads.backgroundThread;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

@:unreflective
class WsClient implements IWsClient {
  final _lock = new RLock();
  final _onOpen: WsClient->Void;
  final _onText: (WsClient, String)->Void;
  final _onError: (WsClient, String)->Void;
  var _client: Null<Star<WsClientAdapter>>;

  public function new(url: String, 
    headers: Null<Map<String, String>>,
    proxy: Null<Proxy>,
    _onOpen: WsClient->Void,
    _onText: (WsClient, String)->Void, 
    _onError: (WsClient, String)->Void)
  {
    // TODO print trust manager
    streamLogger.logDebug('WS connecting: $url headers($headers) proxy($proxy)');
    this._onOpen = _onOpen;
    this._onText = _onText;
    this._onError = _onError;
    // headers
    var hs = new CppStringMap();
    if (headers != null) {
      for (k => v in headers) {
        hs.add(k, v);
      }
    }
    // proxy
    var pc = new ProxyConfig();
    if (proxy != null) {
      pc.setHost(proxy.host);
      pc.setPort(proxy.port);
      if (proxy.user != null) {
        pc.setUsername(proxy.user);
      }
      if (proxy.password != null){
        pc.setPassword(proxy.password);
      }
    }
    // connect
    this._client = new WsClientAdapter(url, Constants.FULL_TLCP_VERSION, hs, pc, () -> onOpen(), s -> onText(s), s -> onError(s));
    _client.connect();
  }

  public function send(txt: String): Void {
    _lock.synchronized(() -> {
      if (_client != null) {
        streamLogger.logDebug('WS sending: $txt');
        // TODO avoid copying string
        _client.send(txt);
      }
    });
  }

  /**
   * **NB** `dispose` method is blocking.
   * Make sure to call it from a different thread than the one calling the `onText`, `onError`, and `onDone` callbacks.
   */
  public function dispose() {
    _lock.synchronized(() -> {
      if (_client != null) {
        var c = _client;
        _client = null;
        streamLogger.logDebug("WS disposing");
        backgroundThread.submit(() -> {
          c.dispose();
          // manually release the memory acquired by the native objects
          untyped __cpp__("delete {0}", c);
        });
      }
    });
  }

  public function isDisposed(): Bool {
    return _lock.synchronized(() -> _client == null);
  }

  function onOpen(): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('WS event: open');
    this._onOpen(this);
  }

  function onText(line: String): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('WS event: text($line)');
    this._onText(this, line);
  }

  function onError(error: String): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('WS event: error($error)');
    this._onError(this, error);
  }
}

@:nativeGen
@:structAccess
class WsClientAdapter extends WsClientCpp {
  final _onOpen: ()->Void;
  final _onText: String->Void;
  final _onError: String->Void;

  public function new(url: String, subProtocol: String, 
    headers: CppStringMap,
    proxy: Reference<ProxyConfig>,
    onOpen: ()->Void,
    onText: String->Void, 
    onError: String->Void) 
  {
    super(url, subProtocol, headers, proxy);
    this._onOpen = onOpen;
    this._onText = onText;
    this._onError = onError;
  }

  override function gc_enter_blocking() {
    cpp.vm.Gc.enterGCFreeZone();
  }

  override function gc_exit_blocking() {
    cpp.vm.Gc.exitGCFreeZone();
  }

  override function submit() {
    var that: Star<WsClientAdapter> = untyped __cpp__("this");
    // TODO use a thread pool?
    @:nullSafety(Off)
    Thread.create(() -> 
      try {
        that.doSubmit();
      } catch(ex) {
        streamLogger.logErrorEx("Uncaught exception in WsClient.hx", ex);
      }
    );
  }

  override public function onOpen(): Void {
    this._onOpen();
  }

  override public function onText(line: ConstCharStar): Void {
    this._onText(line);
  }

  override public function onError(error: ConstCharStar): Void {
    this._onError(error);
  }
}