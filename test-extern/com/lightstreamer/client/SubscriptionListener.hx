package com.lightstreamer.client;

#if python
@:pythonImport("lightstreamer.client", "SubscriptionListener")
#end
#if js @:native("SubscriptionListener") #end
extern interface SubscriptionListener {
  public function onSubscription(): Void;
  public function onSubscriptionError(code:Int, message:String): Void;
  public function onUnsubscription(): Void;
  public function onClearSnapshot(itemName:Null<String>, itemPos:Int): Void;
  public function onItemUpdate(update:ItemUpdate): Void;
  public function onEndOfSnapshot(itemName:Null<String>, itemPos:Int): Void;
  public function onItemLostUpdates(itemName:Null<String>, itemPos:Int, lostUpdates:Int): Void;
  public function onRealMaxFrequency(frequency:Null<String>): Void;
  public function onCommandSecondLevelSubscriptionError(code:Int, message:String, key:String): Void;
  public function onCommandSecondLevelItemLostUpdates(lostUpdates:Int, key:String): Void;
  public function onListenEnd(subscription:Subscription): Void;
  public function onListenStart(subscription:Subscription): Void;
}