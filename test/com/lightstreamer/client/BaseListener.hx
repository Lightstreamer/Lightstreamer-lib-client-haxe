package com.lightstreamer.client;

class BaseClientListener implements ClientListener {
  public function new() {}
  dynamic public function _onStatusChange(status:String) {}
  public function onStatusChange(status:String) _onStatusChange(status);
  dynamic public function _onServerError(code:Int, message:String) {}
  public function onServerError(code:Int, message:String) _onServerError(code, message);
  dynamic public function _onPropertyChange(property:String) {}
  public function onPropertyChange(property:String) _onPropertyChange(property);

  public function onListenEnd(client:LightstreamerClient) {}
  public function onListenStart(client:LightstreamerClient) {}
}

class BaseSubscriptionListener implements SubscriptionListener {
  public function new() {}
  dynamic public function _onSubscription() {}
  public function onSubscription() _onSubscription();
  dynamic public function _onSubscriptionError(code:Int, message:String) {}
  public function onSubscriptionError(code:Int, message:String) _onSubscriptionError(code, message);
  dynamic public function _onUnsubscription() {}
  public function onUnsubscription() _onUnsubscription();
  dynamic public function _onClearSnapshot(itemName:Null<String>, itemPos:Int) {}
  public function onClearSnapshot(itemName:Null<String>, itemPos:Int) _onClearSnapshot(itemName, itemPos);
  dynamic public function _onItemUpdate(update:ItemUpdate) {}
  public function onItemUpdate(update:ItemUpdate) _onItemUpdate(update);
  dynamic public function _onEndOfSnapshot(itemName:Null<String>, itemPos:Int) {}
  public function onEndOfSnapshot(itemName:Null<String>, itemPos:Int) _onEndOfSnapshot(itemName, itemPos);
  dynamic public function _onItemLostUpdates(itemName:Null<String>, itemPos:Int, lostUpdates:Int) {}
  public function onItemLostUpdates(itemName:Null<String>, itemPos:Int, lostUpdates:Int) _onItemLostUpdates(itemName, itemPos, lostUpdates);
  dynamic public function _onRealMaxFrequency(frequency:Null<String>) {}
  public function onRealMaxFrequency(frequency:Null<String>) _onRealMaxFrequency(frequency);

  public function onCommandSecondLevelItemLostUpdates(lostUpdates:Int, key:String) {}
  public function onCommandSecondLevelSubscriptionError(code:Int, message:String, key:String) {}
  public function onListenEnd(subscription:Subscription) {}
  public function onListenStart(subscription:Subscription) {}
}

class BaseMessageListener implements ClientMessageListener {
  public function new() {}
  dynamic public function _onProcessed(originalMessage:String) {}
  public function onProcessed(originalMessage:String) _onProcessed(originalMessage);
  dynamic public function _onDeny(originalMessage:String, code:Int, error:String) {}
  public function onDeny(originalMessage:String, code:Int, error:String) _onDeny(originalMessage, code, error);

  public function onAbort(originalMessage:String, sentOnNetwork:Bool) {}
  public function onDiscarded(originalMessage:String) {}
  public function onError(originalMessage:String) {}
}