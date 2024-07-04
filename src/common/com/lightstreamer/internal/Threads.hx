package com.lightstreamer.internal;

private function createExecutor() {
  #if python
  // workaround for python: see issue https://github.com/HaxeFoundation/haxe/issues/10562
  haxe.Log.trace = (v, ?infos) -> {
    @:nullSafety(Off) var out = haxe.Log.formatOutput(v, infos);
    Sys.println(out);
  };
  #end
  return new Executor();
}

final userThread = createExecutor();
final sessionThread = createExecutor();