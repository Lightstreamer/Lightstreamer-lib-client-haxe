/*
 * Copyright (C) 2023 Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.lightstreamer.client;

class BaseClientListener implements ClientListener {
  public function new() {}
  dynamic public function _onStatusChange(status:String) {}
  public function onStatusChange(status:String) _onStatusChange(status);
  dynamic public function _onServerError(code:Int, message:String) {}
  public function onServerError(code:Int, message:String) _onServerError(code, message);
  dynamic public function _onPropertyChange(property:String) {}
  public function onPropertyChange(property:String) _onPropertyChange(property);
  dynamic public function _onServerKeepalive() {}
  public function onServerKeepalive() _onServerKeepalive();
  public function onListenEnd(#if js client: LightstreamerClient #end) {}
  public function onListenStart(#if js client: LightstreamerClient #end) {}
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
  dynamic public function _onCommandSecondLevelSubscriptionError(code:Int, message:String, key:String) {}
  public function onCommandSecondLevelSubscriptionError(code:Int, message:String, key:String) _onCommandSecondLevelSubscriptionError(code, message, key);
  dynamic public function _onCommandSecondLevelItemLostUpdates(lostUpdates:Int, key:String) {}
  public function onCommandSecondLevelItemLostUpdates(lostUpdates:Int, key:String) _onCommandSecondLevelItemLostUpdates(lostUpdates, key);

  public function onListenEnd(#if js sub: Subscription #end) {}
  public function onListenStart(#if js sub: Subscription #end) {}
}

class BaseMessageListener implements ClientMessageListener {
  public function new() {}
  dynamic public function _onProcessed(msg:String, response: String) {}
  public function onProcessed(msg:String, response: String) _onProcessed(msg, response);
  dynamic public function _onDeny(msg:String, code:Int, error:String) {}
  public function onDeny(msg:String, code:Int, error:String) _onDeny(msg, code, error);
  dynamic public function _onAbort(msg:String, sentOnNetwork:Bool) {}
  public function onAbort(msg:String, sentOnNetwork:Bool) _onAbort(msg, sentOnNetwork);
  dynamic public function _onDiscarded(msg:String) {}
  public function onDiscarded(msg:String) _onDiscarded(msg);
  dynamic public function _onError(msg:String) {}
  public function onError(msg:String) _onError(msg);
}