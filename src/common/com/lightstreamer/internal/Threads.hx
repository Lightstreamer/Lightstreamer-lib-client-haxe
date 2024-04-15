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
#if cpp
// since blocking operations are forbidden within the Lightstreamer Client API, methods that may block must be offloaded to dedicated threads.
// `backgroundThread` is specifically reserved for executing methods that are expected to block only for a short time.
final backgroundThread = createExecutor();
#end