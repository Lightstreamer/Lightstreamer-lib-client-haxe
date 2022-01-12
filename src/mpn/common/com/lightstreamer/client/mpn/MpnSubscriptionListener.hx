package com.lightstreamer.client.mpn;

interface MpnSubscriptionListener {
  public function onListenStart(subscription: MpnSubscription): Void;
  public function onListenEnd(subscription: MpnSubscription): Void;
  public function onSubscription(): Void;
  public function onUnsubscription(): Void;
  public function onSubscriptionError(code: Int, message: String): Void;
  public function onUnsubscriptionError(code: Int, message: String): Void;
  public function onTriggered(): Void;
  public function onStatusChanged(status: String, timestamp: haxe.Int64): Void;
  public function onPropertyChanged(propertyName: String): Void;
}