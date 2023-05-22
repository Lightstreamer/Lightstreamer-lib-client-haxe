package com.lightstreamer.internal;

/**
 * A replacement for `haxe.Timer` using `setTimeout` instead of `setInterval`.
 * 
 * @see `com.lightstreamer.internal.Macros.patchHaxeTimer`
 */
class JsTimer {
  var id:Null<Int>;

  public function new(time_ms: Int) {
    var me = this;
    id = untyped setTimeout(function() me.run(), time_ms);
  }

  public function stop() {
    if (id == null)
			return;
    untyped clearTimeout(id);
    id = null;
  }

  public dynamic function run() {}
}