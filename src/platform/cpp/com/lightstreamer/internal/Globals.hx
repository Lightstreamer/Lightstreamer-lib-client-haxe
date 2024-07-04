package com.lightstreamer.internal;

// import com.lightstreamer.hxpoco.Network;
// import com.lightstreamer.internal.NativeTypes.NativeTrustManager;

@:unreflective
@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();

  function new() {}

  // public function setTrustManagerFactory(ctx: NativeTrustManager) {
  //   Network.setSSLContext(ctx);
  // }

  // public function clearTrustManager() {
  //   Network.clearSSLContext();
  // }

  public function toString(): String return "{}";
}