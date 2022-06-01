package com.lightstreamer.internal;

@:pythonImport("com_lightstreamer_net", "HttpClientPy")
extern class HttpClientPy {
  function new();
  function sendAsync(url: String, body: String, headers: Null<python.Dict<String, String>>, proxy: Null<TypesPy.Proxy>, sslContext: Null<SSLContext>): Void;
  function dispose(): Void;
  function isDisposed(): Bool;
  function on_text(client: HttpClientPy, line: String): Void;
  function on_error(client: HttpClientPy, error: python.Exceptions.BaseException): Void;
  function on_done(client: HttpClientPy): Void;
}