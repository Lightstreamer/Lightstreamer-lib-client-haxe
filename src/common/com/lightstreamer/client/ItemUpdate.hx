package com.lightstreamer.client;

import com.lightstreamer.internal.NativeTypes;

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
  #else
  function getChangedFields(): NativeStringMap1<Null<String>>;
  function getChangedFieldsByPosition(): NativeIntMap1<Null<String>>;
  function getFields(): NativeStringMap1<Null<String>>;
  function getFieldsByPosition(): NativeIntMap1<Null<String>>;
  #end
}