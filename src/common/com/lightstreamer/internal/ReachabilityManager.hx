package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi.ReachabilityStatus;
import com.lightstreamer.internal.PlatformApi.IReachability;

#if LS_WEB
class ReachabilityManager implements IReachability {
  public function new() {}

  public function startListening(onUpdate:ReachabilityStatus -> Void) {
    if (js.Browser.supported) {
      js.Browser.window.ononline = () -> onUpdate(RSReachable);
      js.Browser.window.onoffline = () -> onUpdate(RSNotReachable);
    }
  }

  @:nullSafety(Off)
  public function stopListening() {
    if (js.Browser.supported) {
      js.Browser.window.ononline = null;
      js.Browser.window.onoffline = null;
    }
  }
}
#else
// dummy implementation
class ReachabilityManager implements IReachability {
  public function new() {}
  public function startListening(onUpdate:ReachabilityStatus -> Void) {}
  public function stopListening() {}
}
#end