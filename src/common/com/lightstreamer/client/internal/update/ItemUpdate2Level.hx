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
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;
using com.lightstreamer.client.internal.update.UpdateUtils.CurrFieldValTools;

#if LS_JSON_PATCH
typedef JsonPatchTypeAsReturnedByGetPatch = 
#if js
com.lightstreamer.internal.patch.Json.JsonPatch
#else
String;
#end
#end

class ItemUpdate2Level extends AbstractItemUpdate {
  final m_itemIdx: Pos;
  final m_items: Null<Map<Pos, String>>;
  final m_nFields: Int;
  final m_fields: Null<Map<Pos, String>>;
  final m_fields2: Null<Map<Pos, String>>;
  final m_newValues: Map<Pos, Null<CurrFieldVal>>;
  final m_changedFields: Set<Pos>;
  final m_isSnapshot: Bool;
  #if LS_JSON_PATCH
  final m_jsonPatches: Map<Pos, JsonPatchTypeAsReturnedByGetPatch>;
  #end

  public function new(itemIdx: Pos, sub: Subscription, newValues: Map<Pos, Null<CurrFieldVal>>, changedFields: Set<Pos>, isSnapshot: Bool#if LS_JSON_PATCH, jsonPatches: Map<Pos, JsonPatchTypeAsReturnedByGetPatch>#end) {
    var items = sub.fetch_items();
    var fields = sub.fetch_fields();
    var fields2 = sub.fetch_fields2();
    this.m_itemIdx = itemIdx;
    this.m_items = toMap(items);
    this.m_nFields = sub.fetch_nFields().sure();
    this.m_fields = toMap(fields);
    this.m_fields2 = toMap(fields2);
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
    if (fieldPos == null) {
      return null;
    }
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
  function _getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<JsonPatchTypeAsReturnedByGetPatch> {
    if (fieldNameOrPos is Int) {
      var fieldPos: Int = fieldNameOrPos;
      return m_jsonPatches[fieldPos];
    } else {
      var fieldName = Std.string(fieldNameOrPos);
      var fieldPos = getFieldIdxFromName(fieldName);
      return fieldPos != null ? m_jsonPatches[fieldPos] : null;
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
        var fieldName = getFieldNameFromIdx(fieldPos);
        iterator(fieldName, fieldPos, m_newValues[fieldPos].toString());
      } catch(e) {
        actionLogger.logErrorEx("An exception was thrown while executing the Function passed to the forEachChangedField method", e);
      }
    }
  }

  public function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void {
    for (fieldPos => fieldVal in m_newValues) {
      try {
        var fieldName = getFieldNameFromIdx(fieldPos);
        iterator(fieldName, fieldPos, fieldVal.toString());
      } catch(e) {
        actionLogger.logErrorEx("An exception was thrown while executing the Function passed to the forEachField method", e);
      }
    }
  }
  #end
  #if (!js || LS_TEST)
  public function getChangedFields(): NativeStringMap<Null<String>> {
    if (m_fields == null || m_fields2 == null) {
      throw new IllegalStateException(ItemUpdateBase.NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (fieldPos in m_changedFields) {
      var fieldName = getFieldNameFromIdx(fieldPos);
      if (fieldName != null) {
        res[fieldName] = m_newValues[fieldPos].toString();
      } // else branch should never happen
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
    if (m_fields == null || m_fields2 == null) {
      throw new IllegalStateException(ItemUpdateBase.NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (f => v in m_newValues) {
      var fieldName = getFieldNameFromIdx(f);
      if (fieldName != null) {
        res[fieldName] = v.toString();
      } // else branch should never happen
    }
    return new NativeStringMap(res);
  }

  public function getFieldsByPosition(): NativeIntMap<Null<String>> {
    var map = [for (k => v in m_newValues) k => v.toString()];
    return new NativeIntMap(map);
  }
  #end

  function getValuePos(fieldPos: Int): Null<String> {
    return m_newValues[fieldPos].toString();
  }

  function getValueName(fieldName: String): Null<String> {
    if (m_fields == null && m_fields2 == null) {
      throw new IllegalStateException(ItemUpdateBase.NO_FIELDS);
    }
    var fieldPos = getFieldIdxFromName(fieldName);
    if (fieldPos == null) {
      throw new IllegalArgumentException(ItemUpdateBase.UNKNOWN_FIELD_NAME);
    }
    return m_newValues[fieldPos].toString();
  }

  function isValueChangedPos(fieldPos: Int): Bool {
    return m_changedFields.contains(fieldPos);
  }

  function isValueChangedName(fieldName: String): Bool {
    if (m_fields == null && m_fields2 == null) {
      throw new IllegalStateException(ItemUpdateBase.NO_FIELDS);
    }
    var fieldPos = getFieldIdxFromName(fieldName);
    if (fieldPos == null) {
      throw new IllegalArgumentException(ItemUpdateBase.UNKNOWN_FIELD_NAME);
    }
    return m_changedFields.contains(fieldPos);
  }

  function getFieldNameFromIdx(fieldIdx: Pos): Null<String> {
    if (fieldIdx <= m_nFields) {
      return m_fields != null ? m_fields[fieldIdx] : null;
    } else {
      return m_fields2 != null ? m_fields2[fieldIdx - m_nFields] : null;
    }
  }

  function getFieldIdxFromName(fieldName: String): Null<Pos> {
    var fields; var fields2; var fieldPos;
    if ((fields = m_fields) != null && (fieldPos = findFirstIndex(fields.sure(), fieldName)) != null) {
      return fieldPos;
    } else if ((fields2 = m_fields2) != null && (fieldPos = findFirstIndex(fields2.sure(), fieldName)) != null) {
      return m_nFields + fieldPos.sure();
    } else {
      return null;
    }
  }

  public function toString(): String {
    var s = new StringBuf();
    s.add("[");
    for (i => val in m_newValues) {
      var fieldName = getFieldNameFromIdx(i) ?? Std.string(i);
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