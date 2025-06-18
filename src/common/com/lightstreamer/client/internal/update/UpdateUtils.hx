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
import com.lightstreamer.internal.Types;
import com.lightstreamer.internal.Set;
import com.lightstreamer.log.LoggerTools;

using com.lightstreamer.log.LoggerTools;
using Lambda;
using com.lightstreamer.client.internal.update.UpdateUtils.CurrFieldValTools;
using com.lightstreamer.internal.NullTools;

enum CurrFieldVal {
  StringVal(string: String);
  #if LS_JSON_PATCH
  JsonVal(json: com.lightstreamer.internal.patch.Json);
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
            sessionLogger.logErrorEx('${e.message}', e);
            throw new IllegalStateException('Cannot apply the JSON Patch to the field $f');
          }
        case StringVal(str):
          @:nullSafety(Off)
          var json = null;
          try {
            json = new com.lightstreamer.internal.patch.Json(str);
          } catch(e) {
            sessionLogger.logErrorEx('${e.message}', e);
            throw new IllegalStateException('Cannot convert the field $f to JSON');
          }
          try {
            newValues[f] = JsonVal(json.sure().apply(patch));
          } catch(e) {
            sessionLogger.logErrorEx('${e.message}', e);
            throw new IllegalStateException('Cannot apply the JSON Patch to the field $f');
          }
        case null:
          throw new IllegalStateException('Cannot apply the JSON patch to the field $f because the field is null');
        }
      #end
      #if LS_TLCP_DIFF
      case diffPatch(patch):
        switch currentValues[f] {
          case StringVal(str):
            newValues[f] = StringVal(patch.apply(str));
          case null:
            throw new IllegalStateException('Cannot apply the TLCP-diff to the field $f because the field is null');
          #if LS_JSON_PATCH
          case JsonVal(_):
            throw new IllegalStateException('Cannot apply the TLCP-diff to the field $f because the field is JSON');
          #end
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
      #if LS_TLCP_DIFF
      case diffPatch(_):
        throw new IllegalStateException('Cannot set the field $f because the first update is a TLCP-diff');
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

#if LS_JSON_PATCH
function computeJsonPatches(currentValues: Null<Map<Pos, Null<CurrFieldVal>>>, incomingValues: Map<Pos, FieldValue>): Map<Pos, com.lightstreamer.internal.patch.Json.JsonPatch> {
  if (currentValues != null) {
    var res: Map<Pos, com.lightstreamer.internal.patch.Json.JsonPatch> = [];
    for (f => value in incomingValues) {
      switch value {
      case jsonPatch(patch):
        res[f] = patch;
      case unchanged:
        var curr = currentValues[f];
        if (curr != null && curr.match(JsonVal(_))) {
          res[f] = new com.lightstreamer.internal.patch.Json.JsonPatch("[]");
        }
      case _:
      }
    }
    return res;
  } else {
    return [];
  }
}
#end

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