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
package com.lightstreamer.client.mpn;

import com.lightstreamer.internal.NativeTypes;

class BaseDeviceListener implements MpnDeviceListener {
  public function new() {}
  public function onListenStart(): Void {}
  public function onListenEnd(): Void {}
  dynamic public function _onRegistered(): Void {}
  public function onRegistered(): Void _onRegistered();
  public function onSuspended(): Void {}
  public function onResumed(): Void {}
  dynamic public function _onStatusChanged(status: String, timestamp: Long): Void {}
  public function onStatusChanged(status: String, timestamp: Long): Void _onStatusChanged(status, timestamp);
  dynamic public function _onRegistrationFailed(code: Int, message: String): Void {}
  public function onRegistrationFailed(code: Int, message: String): Void _onRegistrationFailed(code, message);
  dynamic public function _onSubscriptionsUpdated(): Void {}
  public function onSubscriptionsUpdated(): Void _onSubscriptionsUpdated();
}

class BaseMpnSubscriptionListener implements MpnSubscriptionListener {
  public function new() {}
  public function onListenStart(): Void {}
  public function onListenEnd(): Void {}
  dynamic public function _onSubscription(): Void {}
  public function onSubscription(): Void _onSubscription();
  dynamic public function _onUnsubscription(): Void {}
  public function onUnsubscription(): Void _onUnsubscription();
  dynamic public function _onSubscriptionError(code: Int, message: String): Void {}
  public function onSubscriptionError(code: Int, message: String): Void _onSubscriptionError(code, message);
  public function onUnsubscriptionError(code: Int, message: String): Void {}
  dynamic public function _onTriggered(): Void {}
  public function onTriggered(): Void _onTriggered();
  dynamic public function _onStatusChanged(status: String, timestamp: Long): Void {}
  public function onStatusChanged(status: String, timestamp: Long): Void _onStatusChanged(status, timestamp);
  dynamic public function _onPropertyChanged(propertyName: String): Void {}
  public function onPropertyChanged(propertyName: String): Void _onPropertyChanged(propertyName);
  dynamic public function _onModificationError(code: Int, message: String, propertyName: String): Void {}
  public function onModificationError(code: Int, message: String, propertyName: String): Void _onModificationError(code, message, propertyName);
}