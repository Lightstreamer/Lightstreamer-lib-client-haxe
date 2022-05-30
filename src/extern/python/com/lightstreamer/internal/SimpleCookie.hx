package com.lightstreamer.internal;

@:pythonImport("http.cookies", "SimpleCookie")
extern class SimpleCookie {
  function new(dict: python.Dict<String, String>);

  inline function toHaxeArray(): Array<Morsel> {
    return Lambda.array(python.Lib.toHaxeIterable(python.Syntax.code("[{0}[k] for k in {0}]", this)));
  }
}