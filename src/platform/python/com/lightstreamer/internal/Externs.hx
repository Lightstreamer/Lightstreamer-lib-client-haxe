package com.lightstreamer.internal;

@:pythonImport("com_lightstreamer", "SessionPy")
extern class SessionPy {
  static function getInstance(): Any;
  static function freeInstance(): Any;
}

@:pythonImport("com_lightstreamer", "HttpClientPy")
extern class HttpClientPy {
  function new();
  function sendAsync(url: String, body: String, headers: Null<python.Dict<String, String>>): Void;
  function dispose(): Void;
  function isDisposed(): Bool;
  function on_text(client: HttpClientPy, line: String): Void;
  function on_error(client: HttpClientPy, error: python.Exceptions.BaseException): Void;
  function on_done(client: HttpClientPy): Void;
}

@:pythonImport("com_lightstreamer", "WsClientPy")
extern class WsClientPy {
  function new();
  function connectAsync(url: String, protocol: String, headers: Null<python.Dict<String, String>>): Void;
  function sendAsync(txt: String): Void;
  function dispose(): Void;
  function isDisposed(): Bool;
  function on_open(client: WsClientPy): Void;
  function on_text(client: WsClientPy, line: String): Void;
  function on_error(client: WsClientPy, error: python.Exceptions.BaseException): Void;
}