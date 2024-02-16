package com.lightstreamer.internal;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();
  var sslContext: Null<SSLContext>;

  function new() {}

  public function setTrustManagerFactory(factory: SSLContext) {
    if (factory == null) {
      throw new IllegalArgumentException("Expected a non-null SSLContext");
    }
    if (sslContext != null) {
      throw new IllegalStateException("SSLContext already installed");
    }
    sslContext = factory;
  }

  public function getTrustManagerFactory(): Null<SSLContext> {
    return sslContext;
  }

  public function clearTrustManager() {
    sslContext = null;
  }

  public function toString() return "{}";
}