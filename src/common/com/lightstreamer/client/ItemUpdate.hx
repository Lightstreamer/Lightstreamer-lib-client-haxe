package com.lightstreamer.client;

@:nativeGen
interface ItemUpdate {
  public function getItemName(): String;
  public function getItemPos(): Int;
  public function getValue(fieldName: String): String;
  // TODO overload
  // public function getValue(fieldPos: Int): String;
  public function isSnapshot(): Bool;
  public function isValueChanged(fieldName: String): Bool;
  // TODO overload
  // public function isValueChanged(fieldPos: Int): Bool;
  public function getChangedFields(): Map<String, String>;
  public function getChangedFieldsByPosition(): Map<Int, String>;
  public function getFields(): Map<String, String>;
  public function getFieldsByPosition(): Map<Int, String>;
}