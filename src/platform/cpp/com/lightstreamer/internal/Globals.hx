package com.lightstreamer.internal;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();

  var _sslCtx = SSLContext.createDefault();

  function new() {}

  public function setTrustManagerFactory(caFile: String, certificateFile: String, privateKeyFile: String, password: String, verifyCert: Bool) {
    _sslCtx = new SSLContext(caFile, certificateFile, privateKeyFile, password, verifyCert);
  }

  public function getTrustManagerFactory(): SSLContext {
    return _sslCtx;
  }

  public function clearTrustManager() {
    _sslCtx = SSLContext.createDefault();
  }

  public function toString(): String return '{ssl: $_sslCtx}';
}