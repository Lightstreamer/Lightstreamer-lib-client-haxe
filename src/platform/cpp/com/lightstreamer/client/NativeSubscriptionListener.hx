package com.lightstreamer.client;

import cpp.Reference;
import com.lightstreamer.cpp.CppString;

@:structAccess
@:native("Lightstreamer::SubscriptionListener")
@:include("Lightstreamer/SubscriptionListener.h")
extern class NativeSubscriptionListener {
  function onClearSnapshot(itemName: Reference<CppString>, itemPos: Int): Void;
  function onCommandSecondLevelItemLostUpdates(lostUpdates: Int, key: Reference<CppString>): Void;
  function onCommandSecondLevelSubscriptionError(code: Int, message: Reference<CppString>, key: Reference<CppString>): Void;
  function onEndOfSnapshot(itemName: Reference<CppString>, itemPos: Int): Void;
  function onItemLostUpdates(itemName: Reference<CppString>, itemPos: Int, lostUpdates: Int): Void;
  // TODO 1 onItemUpdate
  // function onItemUpdate(update: ItemUpdate): Void;
  function onListenEnd(): Void;
  function onListenStart(): Void;
  function onSubscription(): Void;
  function onSubscriptionError(code: Int, message: Reference<CppString>): Void;
  function onUnsubscription(): Void;
  function onRealMaxFrequency(frequency: Reference<CppString>): Void;
}