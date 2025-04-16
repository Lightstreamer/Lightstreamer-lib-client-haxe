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