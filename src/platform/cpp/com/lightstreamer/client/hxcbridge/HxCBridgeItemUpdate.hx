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

import cpp.ConstStar;
import com.lightstreamer.cpp.CppString;
import com.lightstreamer.cpp.CppIntMap;
import com.lightstreamer.cpp.CppStringMap;

@:unreflective
@:build(HaxeCBridge.expose()) @HaxeCBridge.name("ItemUpdate")
@:publicFields
class HxCBridgeItemUpdate {
  private final _upd: ItemUpdate;

  @:allow(com.lightstreamer.client.hxcbridge.SubscriptionListenerAdapter)
  private function new(upd: ItemUpdate) {
    _upd = upd;
  }

  function getItemName(): CppString {
    return _upd.getItemName() ?? "";
  }

  function getItemPos(): Int {
    return _upd.getItemPos();
  }

  function getValueByName(@:nullSafety(Off) fieldName: ConstStar<CppString>): CppString {
    return _upd.getValueByName(fieldName) ?? "";
  }

  function getValueByPos(fieldPos: Int): CppString {
    return _upd.getValueByPos(fieldPos) ?? "";
  }

  function isNullByName(@:nullSafety(Off) fieldName: ConstStar<CppString>): Bool {
    return _upd.getValueByName(fieldName) == null;
  }

  function isNullByPos(fieldPos: Int): Bool {
    return _upd.getValueByPos(fieldPos) == null;
  }

  function isSnapshot(): Bool {
    return _upd.isSnapshot();
  }

  function isValueChangedByName(@:nullSafety(Off) fieldName: ConstStar<CppString>): Bool {
    return _upd.isValueChangedByName(fieldName);
  }

  function isValueChangedByPos(fieldPos: Int): Bool {
    return _upd.isValueChangedByPos(fieldPos);
  }

  function getChangedFields(): CppStringMap {
    return _upd.getChangedFields();
  }

  function getChangedFieldsByPosition(): CppIntMap {
    return _upd.getChangedFieldsByPosition();
  }

  function getFields(): CppStringMap {
    return _upd.getFields();
  }

  function getFieldsByPosition(): CppIntMap {
    return _upd.getFieldsByPosition();
  }
}