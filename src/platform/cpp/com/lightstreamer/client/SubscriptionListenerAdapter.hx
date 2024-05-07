package com.lightstreamer.client;

import cpp.Pointer;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.client.SubscriptionListener;

class SubscriptionListenerAdapter implements SubscriptionListener {
  final _listener: Pointer<NativeSubscriptionListener>;

  public function new(listener: Pointer<NativeSubscriptionListener>) {
    _listener = listener;
  }

  public function onClearSnapshot(itemName: Null<String>, itemPos: Int): Void {
    var itemName = itemName ?? "";
    _listener.ref.onClearSnapshot(itemName, itemPos);
  }
  public function onCommandSecondLevelItemLostUpdates(lostUpdates: Int, key: String): Void {
    _listener.ref.onCommandSecondLevelItemLostUpdates(lostUpdates, key);
  }
  public function onCommandSecondLevelSubscriptionError(code: Int, message: String, key: String): Void {
    _listener.ref.onCommandSecondLevelSubscriptionError(code, message, key);
  }
  public function onEndOfSnapshot(itemName: Null<String>, itemPos: Int): Void {
    var itemName = itemName ?? "";
    _listener.ref.onEndOfSnapshot(itemName, itemPos);
  }
  public function onItemLostUpdates(itemName: Null<String>, itemPos: Int, lostUpdates: Int): Void {
    var itemName = itemName ?? "";
    _listener.ref.onItemLostUpdates(itemName, itemPos, lostUpdates);
  }
  public function onItemUpdate(update: ItemUpdate): Void {
    // TODO 1
  }
  public function onListenEnd(): Void {
    _listener.ref.onListenEnd();
  }
  public function onListenStart(): Void {
    _listener.ref.onListenStart();
  }
  public function onSubscription(): Void {
    _listener.ref.onSubscription();
  }
  public function onSubscriptionError(code: Int, message: String): Void {
    _listener.ref.onSubscriptionError(code, message);
  }
  public function onUnsubscription(): Void {
    _listener.ref.onUnsubscription();
  }
  public function onRealMaxFrequency(frequency: Null<String>): Void {
    var frequency = frequency ?? "";
    _listener.ref.onRealMaxFrequency(frequency);
  }
}