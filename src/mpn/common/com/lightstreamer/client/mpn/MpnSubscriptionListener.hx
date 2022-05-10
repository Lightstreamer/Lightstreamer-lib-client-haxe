package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.NativeTypes;

#if (java || cs || python) @:nativeGen #end
interface MpnSubscriptionListener {
  public function onListenStart(subscription: MpnSubscription): Void;
  public function onListenEnd(subscription: MpnSubscription): Void;
  public function onSubscription(): Void;
  public function onUnsubscription(): Void;
  public function onSubscriptionError(code: Int, message: String): Void;
  public function onUnsubscriptionError(code: Int, message: String): Void;
  public function onTriggered(): Void;
  public function onStatusChanged(status: String, timestamp: Long): Void;
  public function onPropertyChanged(propertyName: String): Void;
  public function onModificationError(code: Int, message: String, propertyName: String): Void;
}