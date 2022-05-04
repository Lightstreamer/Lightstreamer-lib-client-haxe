package com.lightstreamer.client;

// TODO use NativeMap
#if (java || cs || python) @:nativeGen #end
interface ItemUpdate {
  function getItemName(): Null<String>;
  function getItemPos(): Int;
  function isSnapshot(): Bool;
  #if static
  overload function getValue(fieldName: String): Null<String>;
  overload function getValue(fieldPos: Int): Null<String>;
  overload function isValueChanged(fieldName: String): Bool;
  overload function isValueChanged(fieldPos: Int): Bool;
  #else
  function getValue(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Null<String>;
  function isValueChanged(fieldNameOrPos: haxe.extern.EitherType<String, Int>): Bool;
  #end
  #if js
  function forEachChangedField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  function forEachField(iterator: (fieldName: Null<String>, fieldPos: Int, value: Null<String>) -> Void): Void;
  #else
  function getChangedFields(): Map<String, Null<String>>;
  function getChangedFieldsByPosition(): Map<Int, Null<String>>;
  function getFields(): Map<String, Null<String>>;
  function getFieldsByPosition(): Map<Int, Null<String>>;
  #end
}