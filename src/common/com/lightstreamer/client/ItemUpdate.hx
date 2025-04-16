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
package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes;

#if js @:native("ItemUpdate") #end
#if python @:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ItemUpdate")) #end
#if cs @:using(ItemUpdate.ItemUpdateExtender) #end
#if cpp @:using(ItemUpdate.ItemUpdateExtender) #end
#if cpp interface #else extern interface #end ItemUpdate {
  #if !cs
  function getItemName(): Null<String>;
  function getItemPos(): Int;
  function isSnapshot(): Bool;
  #else
  var ItemName(get, never): Null<String>;
  var ItemPos(get, never): Int;
  var Snapshot(get, never): Bool;
  #end
  #if static
    #if cpp
    function getValueByName(fieldName: String): Null<String>;
    function getValueByPos(fieldPos: Int): Null<String>;
    function isValueChangedByName(fieldName: String): Bool;
    function isValueChangedByPos(fieldPos: Int): Bool;
    #else
    overload function getValue(fieldName: String): Null<String>;
    overload function getValue(fieldPos: Int): Null<String>;
    overload function isValueChanged(fieldName: String): Bool;
    overload function isValueChanged(fieldPos: Int): Bool;
      #if LS_JSON_PATCH
      overload function getValueAsJSONPatchIfAvailable(fieldName: String): Null<String>;
      overload function getValueAsJSONPatchIfAvailable(fieldPos: Int): Null<String>;
      #end
    #end
  #else
  function getValue(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<String>;
  function isValueChanged(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Bool;
    #if LS_JSON_PATCH
      #if js
      function getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<com.lightstreamer.internal.patch.Json.JsonPatch>;
      #else
      function getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<String>;
      #end
    #end
  #end
  #if js
  function forEachChangedField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  #end
  #if (!js || LS_TEST)
    #if !cs
    function getChangedFields(): NativeStringMap<Null<String>>;
    function getChangedFieldsByPosition(): NativeIntMap<Null<String>>;
    function getFields(): NativeStringMap<Null<String>>;
    function getFieldsByPosition(): NativeIntMap<Null<String>>;
    #else
    var ChangedFields(get, never): NativeStringMap<Null<String>>;
    var ChangedFieldsByPosition(get, never): NativeIntMap<Null<String>>;
    var Fields(get, never): NativeStringMap<Null<String>>;
    var FieldsByPosition(get, never): NativeIntMap<Null<String>>;
    #end
  #end
}

#if cs
@:publicFields
class ItemUpdateExtender {
  inline static function getItemName(update: ItemUpdate) return update.ItemName;
  inline static function getItemPos(update: ItemUpdate) return update.ItemPos;
  inline static function isSnapshot(update: ItemUpdate) return update.Snapshot;
  inline static function getChangedFields(update: ItemUpdate) return update.ChangedFields;
  inline static function getChangedFieldsByPosition(update: ItemUpdate) return update.ChangedFieldsByPosition;
  inline static function getFields(update: ItemUpdate) return update.Fields;
  inline static function getFieldsByPosition(update: ItemUpdate) return update.FieldsByPosition;
}
#end

#if cpp
class ItemUpdateExtender {
  static extern inline overload public function getValue(obj: ItemUpdate, fieldPos: Int) return obj.getValueByPos(fieldPos);
  static extern inline overload public function getValue(obj: ItemUpdate, fieldName: String) return obj.getValueByName(fieldName);
  static extern inline overload public function isValueChanged(obj: ItemUpdate, fieldPos: Int) return obj.isValueChangedByPos(fieldPos);
  static extern inline overload public function isValueChanged(obj: ItemUpdate, fieldName: String) return obj.isValueChangedByName(fieldName);
}
#end