package com.lightstreamer.internal;

import com.lightstreamer.client.Proxy;
import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.NativeTypes.IllegalArgumentException;
import cs.system.net.security.RemoteCertificateValidationCallback;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class Globals {
  static public final instance = new Globals();
  var webProxy: Null<Proxy>;
  var validationCallback: Null<RemoteCertificateValidationCallback>;

  function new() {}

  public function setProxy(proxy: Null<Proxy>) {
    if (proxy == null) {
      throw new IllegalArgumentException("Expected a non-null Proxy");
    }
    if (webProxy != null && !webProxy.equals(proxy)) {
      throw new IllegalStateException("Proxy already installed");
    }
    if (webProxy == null) {
      webProxy = proxy;
      HttpClient.setProxy(proxy);
    }
  }

  public function setTrustManagerFactory(callback: RemoteCertificateValidationCallback) {
    if (callback == null) {
      throw new IllegalArgumentException("Expected a non-null RemoteCertificateValidationCallback");
    }
    if (validationCallback != null) {
      throw new IllegalStateException("RemoteCertificateValidationCallback already installed");
    }
    validationCallback = callback;
    HttpClient.setRemoteCertificateValidationCallback(callback);
  }
}