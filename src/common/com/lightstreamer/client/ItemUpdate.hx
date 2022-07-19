package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes;

#if (js || python) @:expose @:native("ItemUpdate") #end
#if (java || cs || python) @:nativeGen #end
interface ItemUpdate {
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
  #end
  #else
  function getValue(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<String>;
  function isValueChanged(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Bool;
  #end
  #if js
  function forEachChangedField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  #end
  #if (!js || LS_TEST)
  function getChangedFields(): NativeStringMap<Null<String>>;
  function getChangedFieldsByPosition(): NativeIntMap<Null<String>>;
  function getFields(): NativeStringMap<Null<String>>;
  function getFieldsByPosition(): NativeIntMap<Null<String>>;
  #end
}