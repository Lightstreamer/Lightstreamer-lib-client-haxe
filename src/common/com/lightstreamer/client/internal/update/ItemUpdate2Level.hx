package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.Set;
import com.lightstreamer.client.internal.update.UpdateUtils;
import com.lightstreamer.internal.MacroTools;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;

class ItemUpdate2Level implements ItemUpdate {
  final m_itemIdx: Pos;
  final m_items: Null<Map<Pos, String>>;
  final m_nFields: Int;
  final m_fields: Null<Map<Pos, String>>;
  final m_fields2: Null<Map<Pos, String>>;
  final m_newValues: Map<Pos, Null<String>>;
  final m_changedFields: Set<Pos>;
  final m_isSnapshot: Bool;

  public function new(itemIdx: Pos, sub: Subscription, newValues: Map<Pos, Null<String>>, changedFields: Set<Pos>, isSnapshot: Bool) {
    var items = sub.getItems();
    var fields = sub.getFields();
    var fields2 = sub.getCommandSecondLevelFields();
    this.m_itemIdx = itemIdx;
    this.m_items = toMap(items != null ? items.toHaxe() : null);
    this.m_nFields = sub.get_nFields().sure();
    this.m_fields = toMap(fields != null ? fields.toHaxe() : null);
    this.m_fields2 = toMap(fields2 != null ? fields2.toHaxe() : null);
    this.m_newValues = newValues;
    this.m_changedFields = changedFields;
    this.m_isSnapshot = isSnapshot;
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
  public function getValueWithFieldPos(fieldPos: Int): Null<String> {
    return getValuePos(fieldPos);
  }

  public function getValue(fieldName: String): Null<String> {
    return getValueName(fieldName);
  }

  public function isValueChangedWithFieldPos(fieldPos: Int): Bool {
    return isValueChangedPos(fieldPos);
  }

  public function isValueChanged(fieldName: String): Bool {
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
  #end

  #if js
  public function forEachChangedField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void {
    for (fieldPos in m_changedFields) {
      try {
        var fieldName = getFieldNameOrNullFromIdx(fieldPos);
        iterator(fieldName, fieldPos, m_newValues[fieldPos]);
      } catch(e) {
        actionLogger.logError("An exception was thrown while executing the Function passed to the forEachChangedField method", cast e);
      }
    }
  }

  public function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void {
    for (fieldPos => fieldVal in m_newValues) {
      try {
        var fieldName = getFieldNameOrNullFromIdx(fieldPos);
        iterator(fieldName, fieldPos, fieldVal);
      } catch(e) {
        actionLogger.logError("An exception was thrown while executing the Function passed to the forEachField method", cast e);
      }
    }
  }
  #else
  public function getChangedFields(): NativeMap<String, Null<String>> {
    if (m_fields == null || m_fields2 == null) {
      throw new IllegalStateException(ItemUpdateBase.NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (fieldPos in m_changedFields) {
      res[getFieldNameFromIdx(fieldPos)] = m_newValues[fieldPos];
    }
    return new NativeMap(res);
  }

  public function getChangedFieldsByPosition(): NativeMap<Int, Null<String>> {
    var res = new Map<Int, Null<String>>();
    for (fieldPos in m_changedFields) {
      res[fieldPos] = m_newValues[fieldPos];
    }
    return new NativeMap(res);
  }

  public function getFields(): NativeMap<String, Null<String>> {
    if (m_fields == null || m_fields2 == null) {
      throw new IllegalStateException(ItemUpdateBase.NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (f => v in m_newValues) {
      res[getFieldNameFromIdx(f)] = v;
    }
    return new NativeMap(res);
  }

  public function getFieldsByPosition(): NativeMap<Int, Null<String>> {
    return new NativeMap(m_newValues);
  }
  #end

  function getValuePos(fieldPos: Int): Null<String> {
    return m_newValues[fieldPos];
  }

  function getValueName(fieldName: String): Null<String> {
    if (m_fields == null && m_fields2 == null) {
      throw new IllegalStateException(ItemUpdateBase.NO_FIELDS);
    }
    var fieldPos = getFieldIdxFromName(fieldName);
    if (fieldPos == null) {
      throw new IllegalArgumentException(ItemUpdateBase.UNKNOWN_FIELD_NAME);
    }
    return m_newValues[fieldPos];
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

  function getFieldNameFromIdx(fieldIdx: Pos): String {
    assert(m_fields != null);
    assert(m_fields2 != null);
    return getFieldNameOrNullFromIdx(fieldIdx).sure();
  }

  function getFieldNameOrNullFromIdx(fieldIdx: Pos): Null<String> {
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
}