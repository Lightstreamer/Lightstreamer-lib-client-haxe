package com.lightstreamer.log;

import cpp.Pointer;

class LoggerProviderAdapter implements LoggerProvider {
  final _provider: Pointer<NativeLoggerProvider>;

  public function new(provider: Pointer<NativeLoggerProvider>) {
    _provider = provider;
  }

  public function getLogger(category: String): Logger {
    var p = Pointer.fromStar(_provider.ref.getLogger(category));
    return new LoggerAdapter(p);
  }
}