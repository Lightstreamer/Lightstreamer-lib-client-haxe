package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.NativeTypes.Long;

@:jsRequire("./ls_web_client_api", "MpnDeviceListener")
extern interface MpnDeviceListener {
  public function onListenStart(): Void;
  public function onListenEnd(): Void;
  public function onRegistered(): Void;
  public function onSuspended(): Void;
  public function onResumed(): Void;
  public function onStatusChanged(status: String, timestamp: Long): Void;
  public function onRegistrationFailed(code: Int, message: String): Void;
  public function onSubscriptionsUpdated(): Void;
}