package com.lightstreamer.client.internal;

import com.lightstreamer.client.NativeTypes.IllegalStateException;

@:build(com.lightstreamer.client.Macros.synchronizeClass())
class Globals {
  public static final instance = new Globals();
  var trustManagerFactory: Null<java.javax.net.ssl.TrustManagerFactory>;

  function new() {}

  public function setTrustManagerFactory(factory: java.javax.net.ssl.TrustManagerFactory) {
    if (factory == null) {
      throw new java.lang.NullPointerException("Expected a non-null TrustManagerFactory");
    }
    if (trustManagerFactory != null) {
      throw new IllegalStateException("Trust manager factory already installed");
    }
    trustManagerFactory = factory;
  }

  public function getTrustManagerFactory(): Null<java.javax.net.ssl.TrustManagerFactory> {
    return trustManagerFactory;
  }
}