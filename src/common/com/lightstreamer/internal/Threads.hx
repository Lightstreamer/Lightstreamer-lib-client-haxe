package com.lightstreamer.internal;

import hx.concurrent.executor.Executor;

private function createExecutor() {
  #if python
  // workaround for python: see issue https://github.com/HaxeFoundation/haxe/issues/10562
  haxe.Log.trace = (v, ?infos) -> {
    @:nullSafety(Off) var out = haxe.Log.formatOutput(v, infos);
    Sys.println(out);
  };
  #end
  return Executor.create();
}

final userThread = createExecutor();
final sessionThread = createExecutor();