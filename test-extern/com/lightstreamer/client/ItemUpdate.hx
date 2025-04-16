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

#if python
@:pythonImport("lightstreamer.client", "ItemUpdate")
#end
#if js @:native("ItemUpdate") #end
#if LS_NODE @:jsRequire("lightstreamer-client-node", "ItemUpdate") #end
extern interface ItemUpdate {
  function getItemName(): Null<String>;
  function getItemPos(): Int;
  function isSnapshot(): Bool;
  #if static
  #if cpp
  function getValue(fieldName: String): Null<String>;
  function getValueWithFieldPos(fieldPos: Int): Null<String>;
  function isValueChanged(fieldName: String): Bool;
  function isValueChangedWithFieldPos(fieldPos: Int): Bool;
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
  function getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<Dynamic>;
  #else
  function getValueAsJSONPatchIfAvailable(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<String>;
  #end
  #end
  #end
  #if js
  function forEachChangedField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  #else
  function getChangedFields(): NativeStringMap<Null<String>>;
  function getChangedFieldsByPosition(): NativeIntMap<Null<String>>;
  function getFields(): NativeStringMap<Null<String>>;
  function getFieldsByPosition(): NativeIntMap<Null<String>>;
  #end
}