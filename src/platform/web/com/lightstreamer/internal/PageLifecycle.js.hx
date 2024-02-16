package com.lightstreamer.internal;

import js.Browser;
import com.lightstreamer.internal.PlatformApi;
import com.lightstreamer.log.LoggerTools.pageLogger;

class PageLifecycle implements IPageLifecycle {
  final onEvent: PageState->Void;
  public var frozen(default, null): Bool = false;

  static public function newLoggingInstance() {
    var glb = new PageLifecycle(e -> pageLogger.logWarn('$e event detected'));
    glb.startListening();
    return glb;
  }

  public function new(onEvent: PageState->Void) {
    this.onEvent = onEvent;
  }

  function handleFrozen() {
    frozen = true;
    onEvent(Frozen);
  }

  function handleResumed() {
    frozen = false;
    onEvent(Resumed);
  }

  public function startListening() {
    if (Browser.supported) {
      Browser.window.addEventListener("freeze", handleFrozen, {capture: true});
      Browser.window.addEventListener("resume", handleResumed, {capture: true});
    }
  }

  public function stopListening() {
    if (Browser.supported) {
      Browser.window.removeEventListener("freeze", handleFrozen, {capture: true});
      Browser.window.removeEventListener("resume", handleResumed, {capture: true});
    }
  }
}
