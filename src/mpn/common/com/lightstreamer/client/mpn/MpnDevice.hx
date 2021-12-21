package com.lightstreamer.client.mpn;

import com.lightstreamer.client.Types.Millis;

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
  public function getStatusTimestamp(): Millis {
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