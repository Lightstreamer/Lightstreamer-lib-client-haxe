package com.lightstreamer.internal;

import com.lightstreamer.internal.PlatformApi.ReachabilityStatus;
import com.lightstreamer.internal.PlatformApi.IReachability;

// TODO NetworkReachabilityManager
class NetworkReachabilityManager implements IReachability {
  public function new() {}
  public function startListening(onUpdate:ReachabilityStatus -> Void) {}
  public function stopListening() {}
}