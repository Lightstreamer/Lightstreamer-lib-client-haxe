package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.Set;

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