package com.lightstreamer.internal;

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
