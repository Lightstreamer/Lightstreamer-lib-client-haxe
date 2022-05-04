package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.Set;
using Lambda;

function mapUpdateValues(oldValues: Null<Map<Pos, Null<String>>>, values: Map<Pos, FieldValue>): Map<Pos, Null<String>> {
  if (oldValues != null) {
    var newValues = new Map<Pos, Null<String>>();
    for (i => fieldValue in values) {
      switch fieldValue {
      case unchanged:
        newValues[i] = oldValues[i];
      case changed(var value):
        newValues[i] = value;
      }
    }
    return newValues;
  } else {
    var newValues = new Map<Pos, Null<String>>();
    for (i => fieldValue in values) {
      switch fieldValue {
      case changed(var value):
        newValues[i] = value;
      default:
        throw new IllegalStateException("Unexpected value");
      }
    }
    return newValues;
  }
}

function findChangedFields(prev: Null<Map<Pos, Null<String>>>, curr: Map<Pos, Null<String>>): Set<Pos> {
  if (prev != null) {
    var changedFields = new Set<Pos>();
    for (i => _ in curr) {
      if (prev[i] != curr[i]) {
        changedFields.insert(i);
      }
    }
    return changedFields;
  } else {
    var changedFields = new Set<Pos>();
    for (i => _ in curr) {
      changedFields.insert(i);
    }
    return changedFields;
  }
}

function toMap(array: Null<Array<String>>): Null<Map<Pos, String>> {
  if (array != null) {
    var map = new Map<Pos, String>();
    for (i => v in array) {
      map[i + 1] = v;
    }
    return map;
  }
  return null;
}

function findFirstIndex(map: Map<Pos, String>, value: String): Null<Pos> {
  for (i in 1...map.count()+1) {
    if (map[i] == value) {
      return i;
    }
  }
  return null;
}