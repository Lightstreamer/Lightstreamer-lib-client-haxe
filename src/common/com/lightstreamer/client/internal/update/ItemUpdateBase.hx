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

import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.Set;
import com.lightstreamer.client.internal.update.UpdateUtils;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;
using com.lightstreamer.client.internal.update.UpdateUtils.CurrFieldValTools;

final NO_FIELDS = "The Subscription was initiated using a Field Schema: the field names are not available";
final POS_OUT_BOUNDS = "The field position is out of bounds";
final UNKNOWN_FIELD_NAME = "The field name is unknown";

class ItemUpdateBase extends AbstractItemUpdate {
  final m_itemIdx: Pos;
  final m_items: Null<Map<Pos, String>>;
  final m_nFields: Int;
  final m_fields: Null<Map<Pos, String>>;
  final m_newValues: Map<Pos, Null<CurrFieldVal>>;
  final m_changedFields: Set<Pos>;
  final m_isSnapshot: Bool;
  #if LS_JSON_PATCH
  final m_jsonPatches: Map<Pos, com.lightstreamer.internal.patch.Json.JsonPatch>;
  #end

  public function new(itemIdx: Pos, sub: Subscription, newValues: Map<Pos, Null<CurrFieldVal>>, changedFields: Set<Pos>, isSnapshot: Bool#if LS_JSON_PATCH, jsonPatches: Map<Pos, com.lightstreamer.internal.patch.Json.JsonPatch>#end) {
    var items = sub.fetch_items();
    var fields = sub.fetch_fields();
    this.m_itemIdx = itemIdx;
    this.m_items = toMap(items);
    this.m_nFields = sub.fetch_nFields().sure();
    this.m_fields = toMap(fields);
    if (fields != null && fields.length != m_nFields) {
      subscriptionLogger.logError('Expected $m_nFields field names but got ${fields.length}: $fields');
    }
    this.m_newValues = newValues.copy();
    this.m_changedFields = changedFields.copy();
    this.m_isSnapshot = isSnapshot;
    #if LS_JSON_PATCH
    this.m_jsonPatches = jsonPatches;
    #end
  }

  public function getItemName(): Null<String> {
    return m_items != null ? m_items[m_itemIdx] : null;
  }

  public function getItemPos(): Int {
    return m_itemIdx;
  }

  public function isSnapshot(): Bool {
    return m_isSnapshot;
  }

  #if static
  #if cpp
  public function getValueByPos(fieldPos: Int): Null<String> {
    return getValuePos(fieldPos);
  }

  public function getValueByName(fieldName: String): Null<String> {
    return getValueName(fieldName);
  }

  public function isValueChangedByPos(fieldPos: Int): Bool {
    return isValueChangedPos(fieldPos);
  }

  public function isValueChangedByName(fieldName: String): Bool {
    return isValueChangedName(fieldName);
  }
  #else
  overload public function getValue(fieldPos: Int): Null<String> {
    return getValuePos(fieldPos);
  }

  overload public function getValue(fieldName: String): Null<String> {
    return getValueName(fieldName);
  }

  overload public function isValueChanged(fieldPos: Int): Bool {
    return isValueChangedPos(fieldPos);
  }

  overload public function isValueChanged(fieldName: String): Bool {
    return isValueChangedName(fieldName);
  }
  #if LS_JSON_PATCH
  overload public function getValueAsJSONPatchIfAvailable(fieldName: String): Null<String> {
    var fieldPos = getFieldIdxFromName(fieldName);
    var val = m_jsonPatches[fieldPos];
    return val != null ? val.toString() : null;
  }
  overload public function getValueAsJSONPatchIfAvailable(fieldPos: Int): Null<String> {
    var val = m_jsonPatches[fieldPos];
    return val != null ? val.toString() : null;
  }
  #end
  #end
  #else
  public function getValue(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<String> {
    if (fieldNameOrPos is Int) {
      var fieldPos: Int = fieldNameOrPos;
      return getValuePos(fieldPos);
    } else {
      var fieldName = Std.string(fieldNameOrPos);
      return getValueName(fieldName);
    }
  }

  public function isValueChanged(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Bool {
    if (fieldNameOrPos is Int) {
      var fieldPos: Int = fieldNameOrPos;
      return isValueChangedPos(fieldPos);
    } else {
      var fieldName = Std.string(fieldNameOrPos);
      return isValueChangedName(fieldName);
    }
  }

  #if LS_JSON_PATCH
  function _getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<com.lightstreamer.internal.patch.Json.JsonPatch> {
    if (fieldNameOrPos is Int) {
      var fieldPos: Int = fieldNameOrPos;
      return m_jsonPatches[fieldPos];
    } else {
      var fieldName = Std.string(fieldNameOrPos);
      var fieldPos = getFieldIdxFromName(fieldName);
      return m_jsonPatches[fieldPos];
    }
  }
  #if js
  public function getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<com.lightstreamer.internal.patch.Json.JsonPatch> {
    return _getValueAsJSONPatchIfAvailable(fieldNameOrPos);
  }
  #else
  public function getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<String> {
    var val = _getValueAsJSONPatchIfAvailable(fieldNameOrPos);
    return val != null ? val.toString() : null;
  }
  #end
  #end
  #end

  #if js
  public function forEachChangedField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void {
    for (fieldPos in m_changedFields) {
      try {
        var fieldName = m_fields != null ? m_fields[fieldPos] : null;
        iterator(fieldName, fieldPos, m_newValues[fieldPos].toString());
      } catch(e) {
        actionLogger.logErrorEx("An exception was thrown while executing the Function passed to the forEachChangedField method", e);
      }
    }
  }

  public function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void {
    for (fieldPos => fieldVal in m_newValues) {
      try {
        var fieldName = m_fields != null ? m_fields[fieldPos] : null;
        iterator(fieldName, fieldPos, fieldVal.toString());
      } catch(e) {
        actionLogger.logErrorEx("An exception was thrown while executing the Function passed to the forEachField method", e);
      }
    }
  }
  #end
  #if (!js || LS_TEST)
  public function getChangedFields(): NativeStringMap<Null<String>> {
    if (m_fields == null) {
      throw new IllegalStateException(NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (fieldPos in m_changedFields) {
      var fieldName = m_fields[fieldPos];
      if (fieldName != null) {
        res[fieldName] = m_newValues[fieldPos].toString();
      } // else branch should never happen: see the check in the ctor
    }
    return new NativeStringMap(res);
  }

  public function getChangedFieldsByPosition(): NativeIntMap<Null<String>> {
    var res = new Map<Int, Null<String>>();
    for (fieldPos in m_changedFields) {
      res[fieldPos] = m_newValues[fieldPos].toString();
    }
    return new NativeIntMap(res);
  }

  public function getFields(): NativeStringMap<Null<String>> {
    if (m_fields == null) {
      throw new IllegalStateException(NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (fieldPos => fieldName in m_fields) {
      res[fieldName] = m_newValues[fieldPos].toString();
    }
    return new NativeStringMap(res);
  }

  public function getFieldsByPosition(): NativeIntMap<Null<String>> {
    var map = [for (k => v in m_newValues) k => v.toString()];
    return new NativeIntMap(map);
  }
  #end

  function getValuePos(fieldPos: Int): Null<String> {
    if (!(1 <= fieldPos && fieldPos <= m_nFields)) {
      throw new IllegalArgumentException(POS_OUT_BOUNDS);
    }
    return m_newValues[fieldPos].toString();
  }

  function getValueName(fieldName: String): Null<String> {
    var fieldPos = getFieldIdxFromName(fieldName);
    return m_newValues[fieldPos].toString();
  }

  function isValueChangedPos(fieldPos: Int): Bool {
    if (!(1 <= fieldPos && fieldPos <= m_nFields)) {
      throw new IllegalArgumentException(POS_OUT_BOUNDS);
    }
    return m_changedFields.contains(fieldPos);
  }

  function isValueChangedName(fieldName: String): Bool {
    var fieldPos = getFieldIdxFromName(fieldName);
    return m_changedFields.contains(fieldPos);
  }

  function getFieldNameOrNullFromIdx(fieldIdx: Pos) {
    return m_fields != null ? m_fields[fieldIdx] : null;
  }

  function getFieldIdxFromName(fieldName: String): Pos {
    if (m_fields == null) {
      throw new IllegalStateException(NO_FIELDS);
    }
    var fieldPos = findFirstIndex(m_fields, fieldName);
    if (fieldPos == null) {
        throw new IllegalArgumentException(UNKNOWN_FIELD_NAME);
    }
    return fieldPos;
  }

  public function toString(): String {
    var s = new StringBuf();
    s.add("[");
    for (i => val in m_newValues) {
      var fieldName = getFieldNameOrNullFromIdx(i) ?? Std.string(i);
      var fieldVal = Std.string(val);
      if (i > 1) {
        s.add(",");
      }
      s.add(fieldName);
      s.add(":");
      s.add(fieldVal);
    }
    s.add("]");
    return s.toString();
  }
}