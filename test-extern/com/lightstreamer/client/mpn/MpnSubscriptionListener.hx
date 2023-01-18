package com.lightstreamer.client.mpn;

#if js @:native("MpnSubscriptionListener") #end
extern interface MpnSubscriptionListener {
  public function onListenStart(): Void;
  public function onListenEnd(): Void;
  public function onSubscription(): Void;
  public function onUnsubscription(): Void;
  public function onSubscriptionError(code: Int, message: String): Void;
  public function onUnsubscriptionError(code: Int, message: String): Void;
  public function onTriggered(): Void;
  public function onStatusChanged(status: String, timestamp: Long): Void;
  public function onPropertyChanged(propertyName: String): Void;
  public function onModificationError(code: Int, message: String, propertyName: String): Void;
}