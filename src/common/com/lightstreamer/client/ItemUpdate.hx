package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes;

#if js @:native("ItemUpdate") #end
@:build(com.lightstreamer.internal.Macros.buildPythonImport("ls_python_client_api", "ItemUpdate"))
#if cs @:using(ItemUpdate.ItemUpdateExtender) #end
extern interface ItemUpdate {
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