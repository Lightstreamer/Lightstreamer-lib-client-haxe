package com.lightstreamer.internal;

#if LS_TEST
@:pythonImport("com_lightstreamer_net", "WsClientPy")
#else
@:pythonImport(".com_lightstreamer_net", "WsClientPy")
#end
extern class WsClientPy {
  function new();
  function connectAsync(url: String, protocol: String, headers: Null<python.Dict<String, String>>, proxy: Null<TypesPy.Proxy>, sslContext: Null<SSLContext>): Void;
  function sendAsync(txt: String): Void;
  function dispose(): Void;
  function isDisposed(): Bool;
  function on_open(client: WsClientPy): Void;
  function on_text(client: WsClientPy, line: String): Void;
  function on_error(client: WsClientPy, error: python.Exceptions.BaseException): Void;
}
