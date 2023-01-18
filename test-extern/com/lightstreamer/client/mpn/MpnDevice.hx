package com.lightstreamer.client.mpn;

#if js @:native("MpnDevice") #end
extern class MpnDevice {
  public function new(deviceToken: String, appId: String, platform: String);
  public function addListener(listener: MpnDeviceListener): Void;
  public function removeListener(listener: MpnDeviceListener): Void;
  public function getListeners(): NativeList<MpnDeviceListener>;
  public function isRegistered(): Bool;
  public function isSuspended(): Bool;
  public function getStatus(): String;
  public function getStatusTimestamp(): Long;
  public function getPlatform(): String;
  public function getApplicationId(): String;
  public function getDeviceToken(): String;
  public function getPreviousDeviceToken(): Null<String>;
  public function getDeviceId(): Null<String>;
}