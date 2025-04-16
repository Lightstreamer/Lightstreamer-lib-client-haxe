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

#if python
@:pythonImport("lightstreamer.client", "SubscriptionListener")
#end
#if js @:native("SubscriptionListener") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "SubscriptionListener") #end
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
  public function onListenEnd(): Void;
  public function onListenStart(): Void;
}