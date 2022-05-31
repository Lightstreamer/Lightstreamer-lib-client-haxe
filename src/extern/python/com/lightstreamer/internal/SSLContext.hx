package com.lightstreamer.internal;

import python.KwArgs;

@:pythonImport("ssl")
@:native("ssl")
extern class SSL {
  static function create_default_context(kwargs: KwArgs<{cafile: String}>): SSLContext;
}

@:pythonImport("ssl", "SSLContext")
extern class SSLContext {
  function load_cert_chain(kwargs: KwArgs<{certfile: String, keyfile: String, ?password: String}>): Void;
}