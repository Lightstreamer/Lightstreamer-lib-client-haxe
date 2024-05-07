package com.lightstreamer.client;

#if js @:native("SubscriptionListener") #end
#if python @:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "SubscriptionListener")) #end
#if cpp interface #else extern interface #end SubscriptionListener {
  function onClearSnapshot(itemName: Null<String>, itemPos: Int): Void;
  function onCommandSecondLevelItemLostUpdates(lostUpdates: Int, key: String): Void;
  function onCommandSecondLevelSubscriptionError(code: Int, message: String, key: String): Void;
  function onEndOfSnapshot(itemName: Null<String>, itemPos: Int): Void;
  function onItemLostUpdates(itemName: Null<String>, itemPos: Int, lostUpdates: Int): Void;
  function onItemUpdate(update: ItemUpdate): Void;
  // NB onListenStart and onListenEnd have the hidden parameter `sub` for the sake of the legacy web widgets
  function onListenEnd(#if js sub: Subscription #end): Void;
  function onListenStart(#if js sub: Subscription #end): Void;
  function onSubscription(): Void;
  function onSubscriptionError(code: Int, message: String): Void;
  function onUnsubscription(): Void;
  function onRealMaxFrequency(frequency: Null<String>): Void;
}