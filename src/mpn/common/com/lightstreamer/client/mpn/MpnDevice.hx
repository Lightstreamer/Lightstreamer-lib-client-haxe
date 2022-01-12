package com.lightstreamer.client.mpn;

class MpnDevice {
  public function addListener(listener: MpnDeviceListener): Void {}
  public function removeListener(listener: MpnDeviceListener): Void {}
  public function getListeners(): Array<MpnDeviceListener> {
    return null;
  }
  public function isRegistered(): Bool {
    return false;
  }
  public function isSuspended(): Bool {
    return false;
  }
  public function getStatus(): String {
    return null;
  }
  public function getStatusTimestamp(): haxe.Int64 {
    return 0;
  }
  public function getApplicationId(): String {
    return null;
  }
  public function getDeviceToken(): String {
    return null;
  }
  public function getPreviousDeviceToken(): String {
    return null;
  }
  public function getDeviceId(): String {
    return null;
  }
  public function getPlatform(): String {
    return null;
  }
}