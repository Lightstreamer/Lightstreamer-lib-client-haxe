package com.lightstreamer.internal;

import cpp.Star;
import cpp.Reference;
import cpp.ConstCharStar;
import sys.thread.Thread;
import lightstreamer.cpp.CppStringMap;
import lightstreamer.hxpoco.HttpClientCpp;
import com.lightstreamer.internal.PlatformApi.IHttpClient;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;

@:unreflective
class HttpClient implements IHttpClient {
  final _onText: (HttpClient, String)->Void;
  final _onError: (HttpClient, String)->Void;
  final _onDone: HttpClient->Void;
  var _client: Null<Star<HttpClientAdapter>>;

  public function new(url: String, body: String, 
    headers: Null<Map<String, String>>,
    _onText: (HttpClient, String)->Void, 
    _onError: (HttpClient, String)->Void, 
    _onDone: HttpClient->Void) 
  {
    streamLogger.logDebug('HTTP sending: $url $body headers($headers)');
    this._onText = _onText;
    this._onError = _onError;
    this._onDone = _onDone;
    var hs = new CppStringMap();
    if (headers != null) {
      for (k => v in headers) {
        hs.add(k, v);
      }
    }
    this._client = new HttpClientAdapter(url, body, hs, s -> onText(s), s -> onError(s), () -> onDone());
    _client.start();
  }

  /**
   * NB `dispose` method is not reentrant.
   * Make sure to call it from a different thread than the one calling the `onText`, `onError`, and `onDone` callbacks.
   */
  public function dispose() {
    streamLogger.logDebug("HTTP disposing");
    if (_client != null) {
      _client.dispose();
      // manually release the memory acquired by the native objects
      untyped __cpp__("delete {0}", _client);
      _client = null;
    }
  }

  inline public function isDisposed(): Bool {
    return _client != null ? _client.isDisposed() : true;
  }

  function onText(line: String): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('HTTP event: text($line)');
    this._onText(this, line);
  }

  function onError(error: String): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug('HTTP event: error($error)');
    this._onError(this, error);
  }

  function onDone(): Void {
    if (isDisposed()) {
      return;
    }
    streamLogger.logDebug("HTTP event: complete");
    this._onDone(this);
  }
}

@:nativeGen
@:structAccess
class HttpClientAdapter extends HttpClientCpp {
  final _onText: String->Void;
  final _onError: String->Void;
  final _onDone: ()->Void;

  public function new(url: String, body: String, 
    headers: CppStringMap,
    onText: String->Void, 
    onError: String->Void, 
    onDone: ()->Void) 
  {
    super(url, body, headers);
    this._onText = onText;
    this._onError = onError;
    this._onDone = onDone;
  }

  override function submit() {
    var that: Reference<HttpClientAdapter> = untyped __cpp__("*this");
    // TODO use a thread pool?
    Thread.create(() -> that.run());
  }

  override public function onText(line: ConstCharStar): Void {
    this._onText(line);
  }

  override public function onError(error: ConstCharStar): Void {
    this._onError(error);
  }

  override public function onDone(): Void {
    this._onDone();
  }
}