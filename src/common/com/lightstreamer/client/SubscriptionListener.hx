package com.lightstreamer.client;

#if (js || python) @:expose @:native("SubscriptionListener") #end
#if (java || cs || python) @:nativeGen #end
interface SubscriptionListener {
  function onClearSnapshot(itemName: Null<String>, itemPos: Int): Void;
  function onCommandSecondLevelItemLostUpdates(lostUpdates: Int, key: String): Void;
  function onCommandSecondLevelSubscriptionError(code: Int, message: String, key: String): Void;
  function onEndOfSnapshot(itemName: Null<String>, itemPos: Int): Void;
  function onItemLostUpdates(itemName: Null<String>, itemPos: Int, lostUpdates: Int): Void;
  function onItemUpdate(update: ItemUpdate): Void;
  function onListenEnd(subscription: Subscription): Void;
  function onListenStart(subscription: Subscription): Void;
  function onSubscription(): Void;
  function onSubscriptionError(code: Int, message: String): Void;
  function onUnsubscription(): Void;
  function onRealMaxFrequency(frequency: Null<String>): Void;
}