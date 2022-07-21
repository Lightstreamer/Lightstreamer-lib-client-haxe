package com.lightstreamer.client.internal.update;

import com.lightstreamer.internal.NativeTypes.IllegalStateException;
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.Set;

using Lambda;
using com.lightstreamer.client.internal.update.UpdateUtils.CurrFieldValTools;

enum CurrFieldVal {
  StringVal(string: String);
  #if LS_JSON_PATCH
  JsonVal(json: com.lightstreamer.internal.diff.Json);
  #end
}

class CurrFieldValTools {
  public static function toString(val: Null<CurrFieldVal>): Null<String> {
    return switch val {
      case null: return null;
      case StringVal(str): return str;
      #if LS_JSON_PATCH
      case JsonVal(json): return json.toString();
      #end
    }
  }
}

function applyUpatesToCurrentFields(currentValues: Null<Map<Pos, Null<CurrFieldVal>>>, incomingValues: Map<Pos, FieldValue>): Map<Pos, Null<CurrFieldVal>> {
  if (currentValues != null) {
    var newValues = new Map<Pos, Null<CurrFieldVal>>();
    for (f => fieldValue in incomingValues) {
      switch fieldValue {
      case unchanged:
        newValues[f] = currentValues[f];
      case changed(var value):
        if (value == null) {
          newValues[f] = null;
        } else {
          newValues[f] = StringVal(value);
        }
      #if LS_JSON_PATCH
      case jsonPatch(patch):
        switch currentValues[f] {
        case JsonVal(json):
          try {
            newValues[f] = JsonVal(json.apply(patch));
          } catch(e) {
            throw new IllegalStateException('Cannot apply the JSON Patch to the field $f', e);
          }
        case StringVal(str):
          @:nullSafety(Off)
          var json = null;
          try {
            json = new com.lightstreamer.internal.diff.Json(str);
          } catch(e) {
            throw new IllegalStateException('Cannot convert the field $f to JSON', e);
          }
          try {
            newValues[f] = JsonVal(json.apply(patch));
          } catch(e) {
            throw new IllegalStateException('Cannot apply the JSON Patch to the field $f', e);
          }
        case null:
          throw new IllegalStateException('Cannot apply the JSON patch to the field $f because the field is null');
        }
      #end
      }
    }
    return newValues;
  } else {
    var newValues = new Map<Pos, Null<CurrFieldVal>>();
    for (f => fieldValue in incomingValues) {
      switch fieldValue {
      case changed(var value):
        if (value == null) {
          newValues[f] = null;
        } else {
          newValues[f] = StringVal(value);
        }
      case unchanged:
        throw new IllegalStateException('Cannot set the field $f because the first update is UNCHANGED');
      #if LS_JSON_PATCH
      case jsonPatch(_):
        throw new IllegalStateException('Cannot set the field $f because the first update is a JSONPatch');
      #end
      }
    }
    return newValues;
  }
}

function findChangedFields(prev: Null<Map<Pos, Null<CurrFieldVal>>>, curr: Map<Pos, Null<CurrFieldVal>>): Set<Pos> {
  if (prev != null) {
    var changedFields = new Set<Pos>();
    for (i => _ in curr) {
      if (prev[i].toString() != curr[i].toString()) {
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

#if js
function getFieldsByPosition(update: ItemUpdate): Map<Int, Null<String>> {
  var res: Map<Int, Null<String>> = [];
  update.forEachField((name, pos, val) -> res[pos] = val);
  return res;
}

function getChangedFieldsByPosition(update: ItemUpdate): Map<Int, Null<String>> {
  var res: Map<Int, Null<String>> = [];
  update.forEachChangedField((name, pos, val) -> res[pos] = val);
  return res;
}
#else
inline function getFieldsByPosition(update: ItemUpdate): Map<Int, Null<String>> {
  return update.getFieldsByPosition();
}

inline function getChangedFieldsByPosition(update: ItemUpdate): Map<Int, Null<String>> {
  return update.getChangedFieldsByPosition();
}
#end