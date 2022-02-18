package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.NativeTypes.Long;

#if (java || cs || python) @:nativeGen #end
interface MpnDeviceListener {
  public function onListenStart(device: MpnDevice): Void;
  public function onListenEnd(device: MpnDevice): Void;
  public function onRegistered(): Void;
  public function onSuspended(): Void;
  public function onResumed(): Void;
  public function onStatusChanged(status: String, timestamp: Long): Void;
  public function onRegistrationFailed(code: Int, message: String): Void;
  public function onSubscriptionsUpdated(): Void;
}