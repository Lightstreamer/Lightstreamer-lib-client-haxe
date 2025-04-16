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
  function onItemUpdate(update: Reference<NativeItemUpdate>): Void;
  function onListenEnd(): Void;
  function onListenStart(): Void;
  function onSubscription(): Void;
  function onSubscriptionError(code: Int, message: Reference<CppString>): Void;
  function onUnsubscription(): Void;
  function onRealMaxFrequency(frequency: Reference<CppString>): Void;
}