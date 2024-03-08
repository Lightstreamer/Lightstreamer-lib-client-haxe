package com.lightstreamer.internal;

import com.lightstreamer.hxpoco.HttpClientCpp;
import com.lightstreamer.internal.NativeTypes.NativeTrustManager;

@:unreflective
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();

  function new() {}

  public function setTrustManagerFactory(ctx: NativeTrustManager) {
    HttpClientCpp.setSSLContext(ctx);
  }

  public function toString(): String return "{}";
}