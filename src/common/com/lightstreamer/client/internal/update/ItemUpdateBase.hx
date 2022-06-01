package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.NativeTypes;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.Set;
import com.lightstreamer.client.internal.update.UpdateUtils;
import com.lightstreamer.log.LoggerTools;
using com.lightstreamer.log.LoggerTools;
using com.lightstreamer.internal.NullTools;

final NO_FIELDS = "The Subscription was initiated using a Field Schema: the field names are not available";
final POS_OUT_BOUNDS = "The field position is out of bounds";
final UNKNOWN_FIELD_NAME = "The field name is unknown";

class ItemUpdateBase implements ItemUpdate {
  final m_itemIdx: Pos;
  final m_items: Null<Map<Pos, String>>;
  final m_nFields: Int;
  final m_fields: Null<Map<Pos, String>>;
  final m_newValues: Map<Pos, Null<String>>;
  final m_changedFields: Set<Pos>;
  final m_isSnapshot: Bool;

  public function new(itemIdx: Pos, sub: Subscription, newValues: Map<Pos, Null<String>>, changedFields: Set<Pos>, isSnapshot: Bool) {
    var items = sub.getItems();
    var fields = sub.getFields();
    this.m_itemIdx = itemIdx;
    this.m_items = toMap(items != null ? items.toHaxe() : null);
    this.m_nFields = sub.fetch_nFields().sure();
    this.m_fields = toMap(fields != null ? fields.toHaxe() : null);
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
        var fieldName = m_fields != null ? m_fields[fieldPos] : null;
        iterator(fieldName, fieldPos, m_newValues[fieldPos]);
      } catch(e) {
        actionLogger.logError("An exception was thrown while executing the Function passed to the forEachChangedField method", cast e);
      }
    }
  }

  public function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void {
    for (fieldPos => fieldVal in m_newValues) {
      try {
        var fieldName = m_fields != null ? m_fields[fieldPos] : null;
        iterator(fieldName, fieldPos, fieldVal);
      } catch(e) {
        actionLogger.logError("An exception was thrown while executing the Function passed to the forEachField method", cast e);
      }
    }
  }
  #else
  public function getChangedFields(): NativeMap<String, Null<String>> {
    if (m_fields == null) {
      throw new IllegalStateException(NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (fieldPos in m_changedFields) {
      res[m_fields[fieldPos].sure()] = m_newValues[fieldPos];
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
    if (m_fields == null) {
      throw new IllegalStateException(NO_FIELDS);
    }
    var res = new Map<String, Null<String>>();
    for (fieldPos => fieldName in m_fields) {
      res[fieldName] = m_newValues[fieldPos];
    }
    return new NativeMap(res);
  }

  public function getFieldsByPosition(): NativeMap<Int, Null<String>> {
    return new NativeMap(m_newValues);
  }
  #end

  function getValuePos(fieldPos: Int): Null<String> {
    if (!(1 <= fieldPos && fieldPos <= m_nFields)) {
      throw new IllegalArgumentException(POS_OUT_BOUNDS);
    }
    return m_newValues[fieldPos];
  }

  function getValueName(fieldName: String): Null<String> {
    if (m_fields == null) {
      throw new IllegalStateException(NO_FIELDS);
    }
    var fieldPos = findFirstIndex(m_fields, fieldName);
    if (fieldPos == null) {
        throw new IllegalArgumentException(UNKNOWN_FIELD_NAME);
    }
    return m_newValues[fieldPos];
  }

  function isValueChangedPos(fieldPos: Int): Bool {
    if (!(1 <= fieldPos && fieldPos <= m_nFields)) {
      throw new IllegalArgumentException(POS_OUT_BOUNDS);
    }
    return m_changedFields.contains(fieldPos);
  }

  function isValueChangedName(fieldName: String): Bool {
    if (m_fields == null) {
      throw new IllegalStateException(NO_FIELDS);
    }
    var fieldPos = findFirstIndex(m_fields, fieldName);
    if (fieldPos == null) {
        throw new IllegalArgumentException(UNKNOWN_FIELD_NAME);
    }
    return m_changedFields.contains(fieldPos);
  }

  function getFieldNameOrNullFromIdx(fieldIdx: Pos) {
    return m_fields != null ? m_fields[fieldIdx] : null;
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