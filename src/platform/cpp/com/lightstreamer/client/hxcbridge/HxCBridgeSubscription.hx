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
package com.lightstreamer.client.hxcbridge;

import cpp.Star;
import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.cpp.CppStringVector;
import com.lightstreamer.internal.NativeTypes.NativeArray;
import com.lightstreamer.client.Subscription.LSSubscription;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("Subscription")
@:publicFields
@:access(com.lightstreamer.client)
class HxCBridgeSubscription {

  /*
   * WARNING: Ensure that the lock is acquired before accessing the class internals.
   */
  
  private final _sub: LSSubscription;
  private final _listeners = new ListenerArray<NativeSubscriptionListener, SubscriptionListenerAdapter>();

  @HaxeCBridge.name("Subscription_new")
  @:nullSafety(Off)
  static function create(mode: ConstStar<CppString>, items: ConstStar<CppStringVector>, fields: ConstStar<CppStringVector>, wrapper: Star<NativeSubscription>) {
    var _items: NativeArray<String> = items.isEmpty() ? null : items;
    var _fields: NativeArray<String> = fields.isEmpty() ? null : fields;
    var _wrapper = wrapper == null ? null : cpp.Pointer.fromStar(wrapper);
    return new HxCBridgeSubscription(mode, _items, _fields, _wrapper);
  }

  private function new(mode: String, items: NativeArray<String>, fields: NativeArray<String>, wrapper: Null<cpp.Pointer<NativeSubscription>>) {
    _sub = new LSSubscription(mode, items, fields, wrapper);
  }

  function addListener(l: cpp.Star<NativeSubscriptionListener>) {
    _sub.lock.synchronized(() -> 
      _listeners.add(l, _sub.addListener)
    );
  }

  function removeListener(l: cpp.Star<NativeSubscriptionListener>) {
    _sub.lock.synchronized(() -> 
      _listeners.remove(l, _sub.removeListener)
    );
  }

  function getListeners(): SubscriptionListenerVector {
    var res = new SubscriptionListenerVector();
    /*
     * WARNING: Do not use the synchronized method; otherwise, the closure will operate on a copy of the vector to be returned.
     */
    _sub.lock.acquire();
      for (l in _listeners) {
        var p: cpp.Pointer<NativeSubscriptionListener> = l._1;
        var pp: cpp.Star<NativeSubscriptionListener> = p.ptr;
        res.push(pp);
      }
    _sub.lock.release();
    return res;
  }

  function isActive() {
    return _sub.isActive();
  }

  function isSubscribed() {
    return _sub.isSubscribed();
  }

  function getDataAdapter(): CppString {
    return _sub.getDataAdapter() ?? "";
  }

  function setDataAdapter(val: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setDataAdapter(val.isEmpty() ? null : val);
  }

  function getMode(): CppString {
    return _sub.getMode();
  }

  function getItems(): CppStringVector {
    var xs = _sub.getItems();
    var res: CppStringVector = xs == null ? new CppStringVector() : xs;
    return res;
  }

  function setItems(items: ConstStar<CppStringVector>) {
    @:nullSafety(Off)
    _sub.setItems(items.isEmpty() ? null : items);
  }

  function getItemGroup(): CppString {
    return _sub.getItemGroup() ?? "";
  }

  function setItemGroup(group: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setItemGroup(group.isEmpty() ? null : group);
  }

  function getFields(): CppStringVector {
    var xs = _sub.getFields();
    var res: CppStringVector = xs == null ? new CppStringVector() : xs;
    return res;
  }

  function setFields(fields: ConstStar<CppStringVector>) {
    @:nullSafety(Off)
    _sub.setFields(fields.isEmpty() ? null : fields);
  }

  function getFieldSchema(): CppString {
    return _sub.getFieldSchema() ?? "";
  }

  function setFieldSchema(schema: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setFieldSchema(schema.isEmpty() ? null : schema);
  }

  function getRequestedBufferSize(): CppString {
    return _sub.getRequestedBufferSize() ?? "";
  }

  function setRequestedBufferSize(buff: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setRequestedBufferSize(buff.isEmpty() ? null : buff);
  }

  function getRequestedSnapshot(): CppString {
    return _sub.getRequestedSnapshot() ?? "";
  }

  function setRequestedSnapshot(snap: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setRequestedSnapshot(snap.isEmpty() ? null : snap);
  }

  function getRequestedMaxFrequency(): CppString {
    return _sub.getRequestedMaxFrequency() ?? "";
  }

  function setRequestedMaxFrequency(freq: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setRequestedMaxFrequency(freq.isEmpty() ? null : freq);
  }

  function getSelector(): CppString {
    return _sub.getSelector() ?? "";
  }

  function setSelector(sel: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setSelector(sel.isEmpty() ? null : sel);
  }

  function getCommandPosition() {
    return _sub.getCommandPosition();
  }

  function getKeyPosition() {
    return _sub.getKeyPosition();
  }

  function getCommandSecondLevelAdapter(): CppString {
    return _sub.getCommandSecondLevelDataAdapter() ?? "";
  }

  function setCommandSecondLevelDataAdapter(adapter: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setCommandSecondLevelDataAdapter(adapter.isEmpty() ? null : adapter);
  }

  function getCommandSecondLevelFields(): CppStringVector {
    var xs = _sub.getCommandSecondLevelFields();
    var res: CppStringVector = xs == null ? new CppStringVector() : xs;
    return res;
  }

  function setCommandSecondLevelFields(fields: ConstStar<CppStringVector>) {
    @:nullSafety(Off)
    _sub.setCommandSecondLevelFields(fields.isEmpty() ? null : fields);
  }

  function getCommandSecondLevelFieldSchema(): CppString {
    return _sub.getCommandSecondLevelFieldSchema() ?? "";
  }

  function setCommandSecondLevelFieldSchema(schema: ConstStar<CppString>) {
    @:nullSafety(Off)
    _sub.setCommandSecondLevelFieldSchema(schema.isEmpty() ? null : schema);
  }

  function getValueSS(@:nullSafety(Off) itemName: ConstStar<CppString>, @:nullSafety(Off) fieldName: ConstStar<CppString>): CppString {
    return _sub.getValueNameName(itemName, fieldName) ?? "";
  }

  function getValueII(itemPos: Int, fieldPos: Int): CppString {
    return _sub.getValuePosPos(itemPos, fieldPos) ?? "";
  }

  function getValueSI(@:nullSafety(Off) itemName: ConstStar<CppString>, fieldPos: Int): CppString {
    return _sub.getValueNamePos(itemName, fieldPos) ?? "";
  }

  function getValueIS(itemPos: Int, @:nullSafety(Off) fieldName: ConstStar<CppString>): CppString {
    return _sub.getValuePosName(itemPos, fieldName) ?? "";
  }

  function getCommandValueSS(@:nullSafety(Off) itemName: ConstStar<CppString>, @:nullSafety(Off) keyValue: ConstStar<CppString>, @:nullSafety(Off) fieldName: ConstStar<CppString>): CppString {
    return _sub.getCommandValueNameName(itemName, keyValue, fieldName) ?? "";
  }

  function getCommandValueII(itemPos: Int, @:nullSafety(Off) keyValue: ConstStar<CppString>, fieldPos: Int): CppString {
    return _sub.getCommandValuePosPos(itemPos, keyValue, fieldPos) ?? "";
  }

  function getCommandValueSI(@:nullSafety(Off) itemName: ConstStar<CppString>, @:nullSafety(Off) keyValue: ConstStar<CppString>, fieldPos: Int): CppString {
    return _sub.getCommandValueNamePos(itemName, keyValue, fieldPos) ?? "";
  }

  function getCommandValueIS(itemPos: Int, @:nullSafety(Off) keyValue: ConstStar<CppString>,  @:nullSafety(Off) fieldName: ConstStar<CppString>): CppString {
    return _sub.getCommandValuePosName(itemPos, keyValue, fieldName) ?? "";
  }
}