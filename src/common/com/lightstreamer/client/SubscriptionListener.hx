package com.lightstreamer.client;

#if python
#if LS_TEST
@:pythonImport("ls_python_client_api", "SubscriptionListener")
#else
@:pythonImport(".ls_python_client_api", "SubscriptionListener")
#end
#end
extern interface SubscriptionListener {
  function onClearSnapshot(itemName: Null<String>, itemPos: Int): Void;
  function onCommandSecondLevelItemLostUpdates(lostUpdates: Int, key: String): Void;
  function onCommandSecondLevelSubscriptionError(code: Int, message: String, key: String): Void;
  function onEndOfSnapshot(itemName: Null<String>, itemPos: Int): Void;
  function onItemLostUpdates(itemName: Null<String>, itemPos: Int, lostUpdates: Int): Void;
  function onItemUpdate(update: ItemUpdate): Void;
  function onListenEnd(): Void;
  function onListenStart(): Void;
  function onSubscription(): Void;
  function onSubscriptionError(code: Int, message: String): Void;
  function onUnsubscription(): Void;
  function onRealMaxFrequency(frequency: Null<String>): Void;
}