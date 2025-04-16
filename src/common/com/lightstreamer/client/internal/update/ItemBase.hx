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
package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.RLock;
import com.lightstreamer.internal.Types;
import com.lightstreamer.client.internal.update.UpdateUtils;

using com.lightstreamer.client.internal.update.UpdateUtils.CurrFieldValTools;

@:build(com.lightstreamer.internal.Macros.synchronizeClass())
class ItemBase {
  public final m_subId: Int;
  public final itemIdx: Pos;
  var currValues: Null<Map<Pos, Null<CurrFieldVal>>>;
  public final subscription: Subscription;
  final client: ClientMachine;
  public final lock: RLock;

  public function new(itemIdx: Pos, sub: Subscription, client: ClientMachine, subId: Int) {
    this.m_subId = subId;
    this.itemIdx = itemIdx;
    this.subscription = sub;
    this.client = client;
    this.lock = client.lock;
  }

  public function finalize() {
    // nothing to do
  }

  public function evtUpdate(values: Map<Pos, FieldValue>) {
    fatalError();
  }
  
  public function evtOnEOS() {
    fatalError();
  }
  
  public function evtOnCS() {
    fatalError();
  }
  
  public function evtDispose(strategy: ModeStrategy) {
    fatalError();
  }
  
  public function getValue(fieldIdx: Pos): Null<String> {
    return currValues != null ? currValues[fieldIdx].toString() : null;
  }
  
  public function getCommandValue(keyName: String, fieldIdx: Pos): Null<String> {
    throw new IllegalStateException("Unsupported operation");
  }

  function fatalError() {
    throw new IllegalStateException("Unsupported operation");
  }

  function doFirstUpdate(values: Map<Pos, FieldValue>) {
    doUpdate(values, false);
  }
  
  function doUpdate0(values: Map<Pos, FieldValue>) {
    doUpdate(values, false);
  }
  
  function doFirstSnapshot(values: Map<Pos, FieldValue>) {
    doUpdate(values, true);
  }
  
  function doSnapshot(values: Map<Pos, FieldValue>) {
    doUpdate(values, true);
  }
  
  function doUpdate(values: Map<Pos, FieldValue>, snapshot: Bool) {
    var prevValues = currValues;
    currValues = applyUpatesToCurrentFields(prevValues, values);
    var changedFields = findChangedFields(prevValues, currValues);
    #if LS_JSON_PATCH
    var jsonPatches = computeJsonPatches(prevValues, values);
    #end
    var update = new ItemUpdateBase(itemIdx, subscription, currValues, changedFields, snapshot#if LS_JSON_PATCH, jsonPatches#end);
    subscription.fireOnItemUpdate(update, m_subId);
  }
}